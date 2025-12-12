import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:young_care/app/common/controller/user_controller.dart';
import 'package:young_care/app/data/models/pedometer_result.dart';
import 'package:young_care/app/data/models/resource.dart';
import 'package:young_care/app/data/repositories/pedometer_repository.dart';

class PedometerController extends GetxController {
  PedometerController({
    PedometerRepository? pedometerRepository,
    UserController? userController,
  })  : _pedometerRepository =
            pedometerRepository ?? Get.find<PedometerRepository>(),
        _userController = userController ?? Get.find<UserController>();

  final PedometerRepository _pedometerRepository;
  final UserController _userController;
  final Distance _distance = const Distance();

  final Rx<Resource<List<PedometerResult>>> dailyResults =
      const Resource<List<PedometerResult>>.initial().obs;
  final Rxn<PedometerResult> selectedResult = Rxn<PedometerResult>();
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    ever(_userController.user, (_) => _refreshForCurrentUser());
  }

  @override
  void onReady() {
    super.onReady();
    _refreshForCurrentUser();
  }

  Future<void> _refreshForCurrentUser() async {
    final String? userId = _userController.userId;
    if (userId == null) {
      dailyResults.value = const Resource<List<PedometerResult>>.empty();
      selectedResult.value = null;
      return;
    }
    await loadForDate(selectedDate.value, userId: userId, updateSelectedDate: false);
  }

  Future<void> loadForDate(
    DateTime date, {
    String? userId,
    bool updateSelectedDate = true,
  }) async {
    final String? resolvedUserId = userId ?? _userController.userId;
    if (resolvedUserId == null) {
      dailyResults.value = const Resource<List<PedometerResult>>.empty();
      selectedResult.value = null;
      return;
    }

    if (updateSelectedDate) {
      selectedDate.value = date;
    }

    final previousData = dailyResults.value.data;
    dailyResults.value = Resource<List<PedometerResult>>.loading(previousData);

    try {
      final DateTime startOfDay = DateTime(date.year, date.month, date.day);
      final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      final rawResults = await _pedometerRepository.fetchByUser(
        userId: resolvedUserId,
        start: startOfDay,
        end: endOfDay,
        descending: true,
      );

      if (rawResults.isEmpty) {
        dailyResults.value = const Resource<List<PedometerResult>>.empty();
        selectedResult.value = null;
        return;
      }

      final results = _withComputedCalories(rawResults);
      dailyResults.value = Resource<List<PedometerResult>>.success(results);
      _selectInitialResult(results);
    } catch (error) {
      dailyResults.value =
          Resource<List<PedometerResult>>.error('Failed to load pedometer data', previousData);
    }
  }

  void selectResult(PedometerResult result) {
    selectedResult.value = result;
  }

  List<PedometerResult> get sessions => dailyResults.value.data ?? const [];

  bool get isLoading => dailyResults.value.isLoading;
  bool get hasError => dailyResults.value.hasError;
  bool get isEmpty => dailyResults.value.status == ResourceStatus.empty;
  String? get errorMessage => dailyResults.value.message;

  String get selectedDateLabel => _formatDate(selectedDate.value);

  String sessionTimeLabel(PedometerResult result) =>
      _formatTime(result.createdAt);

  String sessionDetailLabel(PedometerResult result) =>
      '${_formatDate(result.createdAt)}, ${_formatTime(result.createdAt)}';

  String get selectedDistanceLabel {
    final result = selectedResult.value;
    if (result == null) return '-';
    final kilometers = _distanceFor(result) / 1000;
    if (kilometers <= 0) return '0 km';
    return '${kilometers.toStringAsFixed(kilometers >= 10 ? 1 : 2)} km';
  }

  String get selectedDurationLabel {
    final Duration? duration = _durationFor(selectedResult.value);
    if (duration == null || duration == Duration.zero) {
      return '-';
    }
    return _formatDuration(duration);
  }

  String get selectedPaceLabel {
    final result = selectedResult.value;
    if (result == null) return '-';
    final duration = _durationFor(result);
    final distanceMeters = _distanceFor(result);
    if (duration == null ||
        duration.inSeconds <= 0 ||
        distanceMeters <= 0.0) {
      return '-';
    }
    final paceSeconds = duration.inSeconds / (distanceMeters / 1000);
    final minutes = paceSeconds ~/ 60;
    final seconds = (paceSeconds % 60).round();
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} /km';
  }

  String get selectedCaloriesLabel {
    final result = selectedResult.value;
    final double? calories = result?.burnCalories;
    if (calories == null || calories <= 0) {
      return 'No record';
    }
    return '${calories.toStringAsFixed(calories >= 100 ? 0 : 1)} kcal';
  }

  String get selectedHeartRateLabel {
    final result = selectedResult.value;
    if (result?.heartRate == null || result!.heartRate! <= 0) {
      return 'No record';
    }
    return '${result.heartRate} bpm';
  }

  String get selectedOxygenLabel {
    final result = selectedResult.value;
    if (result?.oxygenUnit == null || result!.oxygenUnit! <= 0) {
      return 'No record';
    }
    return '${result.oxygenUnit}% SpO2';
  }

  String get selectedSummaryLabel {
    final result = selectedResult.value;
    if (result == null) {
      return 'Select a session to see details';
    }
    final String? intensity = _intensitySummary(result);
    if (intensity != null) {
      return intensity;
    }

    final duration = selectedDurationLabel;
    final pace = selectedPaceLabel;
    return 'Duration $duration | Pace $pace';
  }

  List<LatLng> get selectedRoute =>
      selectedResult.value?.positions ?? const <LatLng>[];

  List<PedometerResult> _withComputedCalories(List<PedometerResult> results) {
    final user = _userController.user.value;
    if (user == null) return results;
    bool hasChanges = false;
    final mapped = results.map((result) {
      final calculated = result.calculateBurnCalories(user);
      if (calculated == null) {
        return result;
      }
      hasChanges = true;
      return result.copyWith(burnCalories: calculated);
    }).toList();
    return hasChanges ? mapped : results;
  }

  PedometerResult? _selectInitialResult(List<PedometerResult> results) {
    final previous = selectedResult.value;
    if (previous != null) {
      final match = _findMatching(previous, results);
      if (match != null) {
        selectedResult.value = match;
        return match;
      }
    }
    selectedResult.value = results.first;
    return results.first;
  }

  PedometerResult? _findMatching(
    PedometerResult target,
    List<PedometerResult> candidates,
  ) {
    for (final candidate in candidates) {
      if (target.id != null &&
          candidate.id != null &&
          target.id == candidate.id) {
        return candidate;
      }
      if (candidate.createdAt.isAtSameMomentAs(target.createdAt)) {
        return candidate;
      }
    }
    return null;
  }

  double _distanceFor(PedometerResult? result) {
    if (result == null) return 0.0;
    final points = result.positions;
    if (points.length < 2) return 0.0;
    double accumulator = 0.0;
    for (var index = 1; index < points.length; index++) {
      accumulator += _distance(points[index - 1], points[index]);
    }
    return accumulator;
  }

  Duration? _durationFor(PedometerResult? result) {
    final seconds = result?.totalSeconds;
    if (seconds == null || seconds <= 0) return null;
    return Duration(seconds: seconds);
  }

  String _formatDate(DateTime date) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final month = monthNames[date.month - 1];
    return '${date.day.toString().padLeft(2, '0')} $month ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hours = date.hour.toString().padLeft(2, '0');
    final minutes = date.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String? _intensitySummary(PedometerResult result) {
    final user = _userController.user.value;
    final int? heartRate = result.heartRate;
    if (user == null || heartRate == null || heartRate <= 0) {
      return null;
    }

    final int age = _calculateAge(user.birthday, result.createdAt);
    final int maxHr = 220 - age;
    if (maxHr <= 0) {
      return null;
    }

    final double percent = (heartRate / maxHr) * 100;
    final _IntensityRange? range = _IntensityRange.lookup(percent);
    if (range == null) {
      return null;
    }

    String percentLabel;
    if (!percent.isFinite) {
      percentLabel = '-';
    } else {
      int rounded = percent.round();
      if (rounded < 0) {
        rounded = 0;
      } else if (rounded > 200) {
        rounded = 200;
      }
      percentLabel = rounded.toString();
    }

    return 'Intensity: ${range.label} '
        '(${heartRate.toString()} bpm ≈ $percentLabel% HR max)';
  }

  int _calculateAge(DateTime birthday, DateTime reference) {
    int age = reference.year - birthday.year;
    final bool hasBirthday =
        reference.month > birthday.month ||
            (reference.month == birthday.month && reference.day >= birthday.day);
    if (!hasBirthday) {
      age -= 1;
    }
    return age < 0 ? 0 : age;
  }
}

class _IntensityRange {
  const _IntensityRange({
    required this.minInclusive,
    required this.maxExclusive,
    required this.label,
  });

  final double minInclusive;
  final double maxExclusive;
  final String label;

  static final List<_IntensityRange> _ranges = <_IntensityRange>[
    _IntensityRange(
      minInclusive: 0,
      maxExclusive: 35,
      label: 'Very light',
    ),
    _IntensityRange(
      minInclusive: 35,
      maxExclusive: 55,
      label: 'Light',
    ),
    _IntensityRange(
      minInclusive: 55,
      maxExclusive: 70,
      label: 'Moderate',
    ),
    _IntensityRange(
      minInclusive: 70,
      maxExclusive: 90,
      label: 'Heavy',
    ),
    _IntensityRange(
      minInclusive: 90,
      maxExclusive: 100,
      label: 'Very heavy',
    ),
    _IntensityRange(
      minInclusive: 100,
      maxExclusive: double.infinity,
      label: 'Maximal',
    ),
  ];

  static _IntensityRange? lookup(double percent) {
    for (final _IntensityRange range in _ranges) {
      if (percent >= range.minInclusive && percent < range.maxExclusive) {
        return range;
      }
    }
    return null;
  }
}

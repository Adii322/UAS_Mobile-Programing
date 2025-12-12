import 'package:get/get.dart';
import 'package:young_care/app/common/controller/user_controller.dart';
import 'package:young_care/app/data/models/daily_step_entry.dart';
import 'package:young_care/app/data/models/pedometer_result.dart';
import 'package:young_care/app/data/models/resource.dart';
import 'package:young_care/app/data/repositories/daily_steps_repository.dart';
import 'package:young_care/app/data/repositories/pedometer_repository.dart';

class ActivityController extends GetxController {
  ActivityController({
    PedometerRepository? pedometerRepository,
    DailyStepsRepository? dailyStepsRepository,
    UserController? userController,
  })  : _pedometerRepository =
            pedometerRepository ?? Get.find<PedometerRepository>(),
        _dailyStepsRepository =
            dailyStepsRepository ?? DailyStepsRepository(),
        _userController = userController ?? Get.find<UserController>();

  final PedometerRepository _pedometerRepository;
  final DailyStepsRepository _dailyStepsRepository;
  final UserController _userController;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final Rx<Resource<DailyActivitySummary>> dailySummary =
      const Resource<DailyActivitySummary>.initial().obs;

  @override
  void onInit() {
    super.onInit();
    _normalizeSelectedDate();
    ever(_userController.user, (_) {
      loadDailySummary(date: selectedDate.value, updateSelectedDate: false);
    });
  }

  @override
  void onReady() {
    super.onReady();
    loadDailySummary();
  }

  String get selectedDateLabel => _formatDate(selectedDate.value);

  Future<void> refresh() => loadDailySummary(date: selectedDate.value);

  Future<void> loadDailySummary({
    DateTime? date,
    bool updateSelectedDate = true,
  }) async {
    final String? userId = _userController.userId;
    if (userId == null || userId.isEmpty) {
      dailySummary.value = const Resource<DailyActivitySummary>.empty();
      return;
    }

    final DateTime targetDate = _normalizeDate(date ?? DateTime.now());
    if (updateSelectedDate) {
      selectedDate.value = targetDate;
    }

    final DailyActivitySummary? previous = dailySummary.value.data;
    dailySummary.value = Resource<DailyActivitySummary>.loading(previous);

    try {
      final DateTime startOfDay =
          DateTime(targetDate.year, targetDate.month, targetDate.day);
      final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

      final PedometerResult? pedometer =
          await _pedometerRepository.fetchLatestToday(
        userId: userId,
        reference: targetDate,
      );

      final List<DailyStepEntry> entries =
          await _dailyStepsRepository.fetchEntries(
        userId: userId,
        start: startOfDay,
        end: endOfDay,
        ascending: true,
      );

      final int totalSteps =
          _dailyStepsRepository.calculateCumulativeSteps(entries);

      final DailyActivitySummary summary = _buildSummary(
        steps: totalSteps,
        pedometer: pedometer,
        date: targetDate,
      );

      dailySummary.value = Resource<DailyActivitySummary>.success(summary);
    } catch (error, stackTrace) {
      Get.log(
        'Failed to load daily activity summary: $error',
        isError: true,
      );
      Get.log(stackTrace.toString(), isError: true);
      dailySummary.value = Resource<DailyActivitySummary>.error(
        'Failed to load activity summary',
        dailySummary.value.data,
      );
    }
  }

  DailyActivitySummary _buildSummary({
    required int steps,
    required DateTime date,
    PedometerResult? pedometer,
  }) {
    final int? heartRate = pedometer?.heartRate;
    final int? spo2 = pedometer?.oxygenUnit;
    final DailyHealthScore? healthScore = _calculateHealthScore(
      heartRate: heartRate,
      spo2: spo2,
      steps: steps,
    );

    return DailyActivitySummary(
      steps: steps,
      heartRate: heartRate,
      spo2: spo2,
      healthScore: healthScore,
      date: date,
    );
  }

  DailyHealthScore? _calculateHealthScore({
    required int? heartRate,
    required int? spo2,
    required int steps,
  }) {
    final double activityScore = _scoreForActivity(steps);
    final double? heartRateScore = _scoreForHeartRate(heartRate);
    final double? spo2Score = _scoreForSpo2(spo2);

    const double heartRateWeight = 0.3;
    const double spo2Weight = 0.4;
    const double activityWeight = 0.3;

    double weightedSum = 0;
    double weightSum = 0;

    if (heartRateScore != null) {
      weightedSum += heartRateScore * heartRateWeight;
      weightSum += heartRateWeight;
    }

    if (spo2Score != null) {
      weightedSum += spo2Score * spo2Weight;
      weightSum += spo2Weight;
    }

    weightedSum += activityScore * activityWeight;
    weightSum += activityWeight;

    if (weightSum <= 0) {
      return null;
    }

    final double finalScore = weightedSum / weightSum;
    final String category = _categoryForScore(finalScore);
    final String recommendation = _recommendationForScore(finalScore);

    return DailyHealthScore(
      value: finalScore,
      heartRateScore: heartRateScore,
      spo2Score: spo2Score,
      activityScore: activityScore,
      category: category,
      recommendation: recommendation,
    );
  }

  double? _scoreForHeartRate(int? heartRate) {
    if (heartRate == null || heartRate <= 0) return null;
    final double normalized =
        100 - ((heartRate - 70).abs() / 30.0 * 100.0);
    if (!normalized.isFinite) return null;
    return normalized.clamp(0, 100).toDouble();
  }

  double? _scoreForSpo2(int? spo2) {
    if (spo2 == null || spo2 <= 0) return null;
    double score;
    if (spo2 >= 98) {
      score = 100;
    } else {
      score = (spo2 - 90) * 12.5;
    }
    if (!score.isFinite) return null;
    return score.clamp(0, 100).toDouble();
  }

  double _scoreForActivity(int steps) {
    if (steps <= 0) return 0;
    final double score = (steps / 8000.0) * 100.0;
    if (!score.isFinite) return 0;
    final double clamped = score.clamp(0, 100).toDouble();
    return clamped;
  }

  String _categoryForScore(double score) {
    if (score >= 85) return 'Excellent';
    if (score >= 70) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Needs attention';
  }

  String _recommendationForScore(double score) {
    if (score >= 85) {
      return 'Keep up your healthy habits.';
    }
    if (score >= 70) {
      return 'You are doing well—stay active and manage stress.';
    }
    if (score >= 50) {
      return 'Increase activity and prioritise quality rest.';
    }
    return 'Review sleep habits and consider consulting a professional.';
  }

  void _normalizeSelectedDate() {
    selectedDate.value = _normalizeDate(selectedDate.value);
  }

  DateTime _normalizeDate(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  String _formatDate(DateTime date) {
    const List<String> monthNames = <String>[
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
    final String month = monthNames[date.month - 1];
    return '${date.day.toString().padLeft(2, '0')} $month ${date.year}';
  }
}

class DailyActivitySummary {
  const DailyActivitySummary({
    required this.steps,
    required this.date,
    this.heartRate,
    this.spo2,
    this.healthScore,
  });

  final int steps;
  final int? heartRate;
  final int? spo2;
  final DailyHealthScore? healthScore;
  final DateTime date;
}

class DailyHealthScore {
  const DailyHealthScore({
    required this.value,
    required this.category,
    required this.recommendation,
    required this.activityScore,
    this.heartRateScore,
    this.spo2Score,
  });

  final double value;
  final double activityScore;
  final double? heartRateScore;
  final double? spo2Score;
  final String category;
  final String recommendation;
}

import 'package:collection/collection.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:young_care/app/common/controller/user_controller.dart';
import 'package:young_care/app/data/models/pedometer_result.dart';
import 'package:young_care/app/data/models/resource.dart';
import 'package:young_care/app/data/models/user_model.dart';
import 'package:young_care/app/data/models/daily_step_entry.dart';
import 'package:young_care/app/data/repositories/pedometer_repository.dart';
import 'package:young_care/app/data/repositories/daily_steps_repository.dart';
import 'package:young_care/app/modules/data_history/models/data_history_models.dart';

class DataHistoryController extends GetxController {
  DataHistoryController({
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
  final Distance _distance = const Distance();

  final Rx<Resource<List<DataHistoryMetric>>> metrics =
      const Resource<List<DataHistoryMetric>>.initial().obs;

  final Rx<DataHistoryMetricType> _selectedType =
      DataHistoryMetricType.steps.obs;

  DataHistoryMetricType get selectedType => _selectedType.value;

  DataHistoryMetric? get selectedMetric =>
      metrics.value.data?.firstWhereOrNull(
        (metric) => metric.type == _selectedType.value,
      );

  List<DataHistoryMetric> get allMetrics =>
      metrics.value.data ?? const <DataHistoryMetric>[];

  @override
  void onInit() {
    super.onInit();
    _hydrateInitialSelection();
    ever(_userController.user, (_) => _loadMetrics());
  }

  @override
  void onReady() {
    super.onReady();
    _loadMetrics();
  }

  Future<void> refresh() => _loadMetrics(force: true);

  void selectMetric(DataHistoryMetricType type) {
    if (_selectedType.value == type) return;
    _selectedType.value = type;
  }

  void _hydrateInitialSelection() {
    final dynamic argument = Get.arguments;
    if (argument is DataHistoryMetricType) {
      _selectedType.value = argument;
      return;
    }
    if (argument is Map && argument['metricType'] is DataHistoryMetricType) {
      _selectedType.value = argument['metricType'] as DataHistoryMetricType;
    }
  }

  Future<void> _loadMetrics({bool force = false}) async {
    final String? userId = _userController.userId;
    final UserModel? user = _userController.user.value;

    if (userId == null || user == null) {
      metrics.value = const Resource<List<DataHistoryMetric>>.empty();
      return;
    }

    final Resource<List<DataHistoryMetric>> previous = metrics.value;
    if (!force && previous.status == ResourceStatus.loading) {
      return;
    }

    metrics.value = Resource<List<DataHistoryMetric>>.loading(previous.data);

    try {
      final DateTime today = DateTime.now();
      final DateTime start = DateTime(today.year, today.month, today.day)
          .subtract(const Duration(days: 6));
      final DateTime endExclusive = DateTime(
        today.year,
        today.month,
        today.day,
      ).add(const Duration(days: 1));

      final List<PedometerResult> rawResults =
          await _pedometerRepository.fetchByUser(
        userId: userId,
        start: start,
        end: endExclusive,
        descending: false,
      );

      final List<PedometerResult> enrichedResults =
          rawResults.map((result) => _enrichCalories(result, user)).toList();

      final List<DailyStepEntry> stepEntries =
          await _dailyStepsRepository.fetchEntries(
        userId: userId,
        start: start,
        end: endExclusive,
        ascending: true,
      );

      final Map<DateTime, int> stepsByDay =
          _groupStepsByDay(stepEntries);

      final List<_DailySummary> summaries =
          _summariesForRange(enrichedResults, start, 7, user, stepsByDay);

      final List<DataHistoryMetric> builtMetrics =
          _buildMetricsFromSummaries(summaries);

      if (builtMetrics.isEmpty ||
          builtMetrics.every((metric) => !metric.hasData)) {
        metrics.value = const Resource<List<DataHistoryMetric>>.empty();
      } else {
        metrics.value = Resource<List<DataHistoryMetric>>.success(builtMetrics);
        if (!builtMetrics.any((metric) => metric.type == _selectedType.value)) {
          _selectedType.value = builtMetrics.first.type;
        }
      }
    } catch (error, stackTrace) {
      metrics.value = Resource<List<DataHistoryMetric>>.error(
        'Failed to load history data',
        metrics.value.data,
      );
      Get.log('Failed to load data history: $error', isError: true);
      Get.log(stackTrace.toString(), isError: true);
    }
  }

  PedometerResult _enrichCalories(PedometerResult result, UserModel user) {
    if (result.burnCalories != null && result.burnCalories! > 0) {
      return result;
    }
    final double? calculated = result.calculateBurnCalories(user);
    if (calculated == null) return result;
    return result.copyWith(burnCalories: calculated);
  }

  List<_DailySummary> _summariesForRange(
    List<PedometerResult> results,
    DateTime start,
    int days,
    UserModel user,
    Map<DateTime, int> stepsByDay,
  ) {
    final Map<DateTime, _DailyAccumulator> accumulators = <DateTime, _DailyAccumulator>{
      for (int index = 0; index < days; index++)
        _normalizeDate(start.add(Duration(days: index))):
            _DailyAccumulator(),
    };

    for (final result in results) {
      final DateTime key = _normalizeDate(result.createdAt);
      final _DailyAccumulator? accumulator = accumulators[key];
      if (accumulator == null) continue;

      accumulator.sessions += 1;

      final double distanceMeters = _distanceFor(result);
      if (distanceMeters > 0) {
        accumulator.totalDistanceMeters += distanceMeters;
      }

      final int seconds = result.totalSeconds ?? 0;
      if (seconds > 0) {
        accumulator.totalDurationSeconds += seconds;
      }

      final double? calories = result.burnCalories;
      if (calories != null && calories > 0) {
        accumulator.totalCalories += calories;
      }

      final int? heartRate = result.heartRate;
      if (heartRate != null && heartRate > 0) {
        accumulator.heartRateSum += heartRate;
        accumulator.heartRateCount += 1;
        if (accumulator.maxHeartRate == null ||
            heartRate > accumulator.maxHeartRate!) {
          accumulator.maxHeartRate = heartRate;
        }
      }

      final int? oxygen = result.oxygenUnit;
      if (oxygen != null && oxygen > 0) {
        accumulator.oxygenSum += oxygen;
        accumulator.oxygenCount += 1;
      }
    }

    return accumulators.entries
        .map(
          (entry) => _DailySummary(
            date: entry.key,
            sessions: entry.value.sessions,
            calories: entry.value.totalCalories,
            averageHeartRate: entry.value.heartRateCount > 0
                ? entry.value.heartRateSum / entry.value.heartRateCount
                : null,
            maxHeartRate: entry.value.maxHeartRate?.toDouble(),
            averageOxygen: entry.value.oxygenCount > 0
                ? entry.value.oxygenSum / entry.value.oxygenCount
                : null,
              totalDistanceMeters: entry.value.totalDistanceMeters,
              totalDurationSeconds: entry.value.totalDurationSeconds,
              steps: stepsByDay[entry.key] ?? 0,
              mets: _calculateMets(
                entry.value.totalCalories,
                user.weight,
                entry.value.totalDurationSeconds,
              ),
          ),
          )
          .sortedBy((summary) => summary.date);
  }

  Map<DateTime, int> _groupStepsByDay(List<DailyStepEntry> entries) {
    final Map<DateTime, List<DailyStepEntry>> grouped =
        <DateTime, List<DailyStepEntry>>{};

    for (final DailyStepEntry entry in entries) {
      final DateTime key = _normalizeDate(entry.createdAt);
      grouped.putIfAbsent(key, () => <DailyStepEntry>[]).add(entry);
    }

    final Map<DateTime, int> totals = <DateTime, int>{};
    grouped.forEach((DateTime date, List<DailyStepEntry> values) {
      totals[date] = _dailyStepsRepository.calculateCumulativeSteps(values);
    });

    return totals;
  }

  List<DataHistoryMetric> _buildMetricsFromSummaries(
    List<_DailySummary> summaries,
  ) {
    if (summaries.isEmpty) {
      return const <DataHistoryMetric>[];
    }

    DataHistoryPoint pointFor(
      _DailySummary summary,
      double? value,
    ) {
      return DataHistoryPoint(
        date: summary.date,
        value: value != null && value.isFinite && value > 0 ? value : 0,
      );
    }

    final List<DataHistoryMetric> result = <DataHistoryMetric>[
      DataHistoryMetric(
        type: DataHistoryMetricType.steps,
        points: summaries
            .map(
              (summary) =>
                  pointFor(summary, summary.steps.toDouble()),
            )
            .toList(),
      ),
      DataHistoryMetric(
        type: DataHistoryMetricType.burnCalories,
        points: summaries
            .map(
              (summary) =>
                  pointFor(summary, summary.calories == 0 ? null : summary.calories),
            )
            .toList(),
      ),
      DataHistoryMetric(
        type: DataHistoryMetricType.heartRate,
        points: summaries
            .map(
              (summary) =>
                  pointFor(summary, summary.averageHeartRate),
            )
            .toList(),
      ),
      DataHistoryMetric(
        type: DataHistoryMetricType.maxHeartRate,
        points: summaries
            .map(
              (summary) =>
                  pointFor(summary, summary.maxHeartRate),
            )
            .toList(),
      ),
      DataHistoryMetric(
        type: DataHistoryMetricType.mets,
        points: summaries
            .map(
              (summary) => pointFor(summary, summary.mets),
            )
            .toList(),
      ),
      DataHistoryMetric(
        type: DataHistoryMetricType.oxygen,
        points: summaries
            .map(
              (summary) => pointFor(summary, summary.averageOxygen),
            )
            .toList(),
      ),
      DataHistoryMetric(
        type: DataHistoryMetricType.cardioRespiratory,
        points: summaries
            .map(
              (summary) => pointFor(summary, summary.vo2Max),
            )
            .toList(),
      ),
    ];

    return result;
  }

  double _distanceFor(PedometerResult result) {
    final List<LatLng> points = result.positions;
    if (points.length < 2) return 0;
    double total = 0;
    for (var index = 1; index < points.length; index++) {
      total += _distance(points[index - 1], points[index]);
    }
    return total;
  }

  double? _calculateMets(
    double calories,
    double weight,
    int durationSeconds,
  ) {
    if (calories <= 0 || weight <= 0 || durationSeconds <= 0) return null;
    final double durationMinutes = durationSeconds / 60;
    if (durationMinutes <= 0) return null;
    final double mets =
        (calories * 200) / (3.5 * weight * durationMinutes);
    if (!mets.isFinite || mets <= 0) return null;
    return mets;
  }

  DateTime _normalizeDate(DateTime raw) =>
      DateTime(raw.year, raw.month, raw.day);
}

class _DailyAccumulator {
  int sessions = 0;
  double totalCalories = 0;
  double totalDistanceMeters = 0;
  int totalDurationSeconds = 0;
  double heartRateSum = 0;
  int heartRateCount = 0;
  int? maxHeartRate;
  double oxygenSum = 0;
  int oxygenCount = 0;
}

class _DailySummary {
  _DailySummary({
    required this.date,
    required this.sessions,
    required this.calories,
    required this.averageHeartRate,
    required this.maxHeartRate,
    required this.averageOxygen,
    required this.totalDistanceMeters,
    required this.totalDurationSeconds,
    required this.steps,
    required this.mets,
  });

  final DateTime date;
  final int sessions;
  final double calories;
  final double? averageHeartRate;
  final double? maxHeartRate;
  final double? averageOxygen;
  final double totalDistanceMeters;
  final int totalDurationSeconds;
  final int steps;
  final double? mets;

  double? get vo2Max => mets != null ? mets! * 3.5 : null;
}

import 'dart:math' as math;

import 'package:young_care/app/core/constants/my_icon.dart';

enum DataHistoryMetricType {
  steps,
  burnCalories,
  heartRate,
  maxHeartRate,
  mets,
  oxygen,
  cardioRespiratory,
}

extension DataHistoryMetricTypeX on DataHistoryMetricType {
  String get label {
    switch (this) {
      case DataHistoryMetricType.steps:
        return 'Steps';
      case DataHistoryMetricType.burnCalories:
        return 'Burn Calories';
      case DataHistoryMetricType.heartRate:
        return 'Heart Rate';
      case DataHistoryMetricType.maxHeartRate:
        return 'Maximum Heart Rate';
      case DataHistoryMetricType.mets:
        return 'METS Results Interpretasion';
      case DataHistoryMetricType.oxygen:
        return 'Oxygen/Unit';
      case DataHistoryMetricType.cardioRespiratory:
        return 'Cardiorespiratory Fitness Presentation';
    }
  }

  String? get unit {
    switch (this) {
      case DataHistoryMetricType.steps:
        return 'steps';
      case DataHistoryMetricType.burnCalories:
        return 'kcal';
      case DataHistoryMetricType.heartRate:
      case DataHistoryMetricType.maxHeartRate:
        return 'bpm';
      case DataHistoryMetricType.mets:
        return 'METs';
      case DataHistoryMetricType.oxygen:
        return '%';
      case DataHistoryMetricType.cardioRespiratory:
        return 'ml/kg/min';
    }
  }

  String get iconAsset {
    switch (this) {
      case DataHistoryMetricType.steps:
        return MyIcon.stepsIcon;
      case DataHistoryMetricType.burnCalories:
        return MyIcon.burnCaloriesIcon;
      case DataHistoryMetricType.heartRate:
        return MyIcon.heartRateIcon;
      case DataHistoryMetricType.maxHeartRate:
        return MyIcon.maxHeartRateIcon;
      case DataHistoryMetricType.mets:
        return MyIcon.metsIcon;
      case DataHistoryMetricType.oxygen:
        return MyIcon.oxygenIcon;
      case DataHistoryMetricType.cardioRespiratory:
        return MyIcon.cardioRespiratoryIcon;
    }
  }
}

class DataHistoryPoint {
  const DataHistoryPoint({
    required this.date,
    required this.value,
  });

  final DateTime date;
  final double value;
}

class DataHistoryMetric {
  const DataHistoryMetric({
    required this.type,
    required this.points,
    this.description,
  });

  final DataHistoryMetricType type;
  final List<DataHistoryPoint> points;
  final String? description;

  String get label => type.label;
  String? get unit => type.unit;
  String get iconAsset => type.iconAsset;

  List<DataHistoryPoint> get _nonZeroPoints =>
      points.where((point) => point.value > 0).toList();

  bool get hasData => _nonZeroPoints.isNotEmpty;

  double? get latestValue =>
      points.isEmpty ? null : points.last.value;

  double? get averageValue {
    final filtered = _nonZeroPoints;
    if (filtered.isEmpty) return null;
    final total = filtered.fold<double>(
      0,
      (sum, point) => sum + point.value,
    );
    return total / filtered.length;
  }

  double? get maxValue {
    final filtered = _nonZeroPoints;
    if (filtered.isEmpty) return null;
    return filtered
        .map((point) => point.value)
        .reduce(math.max);
  }

  double? get minValue {
    final filtered = _nonZeroPoints;
    if (filtered.isEmpty) return null;
    return filtered
        .map((point) => point.value)
        .reduce(math.min);
  }
}


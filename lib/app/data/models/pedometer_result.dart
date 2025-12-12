import 'package:latlong2/latlong.dart';
import 'package:young_care/app/data/models/user_model.dart';

class PedometerResult {
  const PedometerResult({
    required this.userId,
    required this.createdAt,
    this.id,
    this.positions = const <LatLng>[],
    this.heartRate,
    this.oxygenUnit,
    this.burnCalories,
    this.totalSeconds,
  });

  final String userId;
  final DateTime createdAt;
  final String? id;
  final List<LatLng> positions;
  final int? heartRate;
  final int? oxygenUnit;
  final double? burnCalories;
  final int? totalSeconds;

  factory PedometerResult.fromMap(Map<String, dynamic> map) {
    return PedometerResult(
      id: map['id']?.toString(),
      userId: map['user_id']?.toString() ?? '',
      createdAt: _parseDateTime(map['created_at']),
      positions: _parsePositions(map['positions']),
      heartRate: _parseInt(map['heart_rate']),
      oxygenUnit: _parseInt(map['oxygen_unit']),
      burnCalories: _parseDouble(map['burn_calories'] ?? map['calories']),
      totalSeconds: _parseInt(map['total_seconds']),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'positions': positions
          .map((position) => {'lat': position.latitude, 'lng': position.longitude})
          .toList(),
      'heart_rate': heartRate,
      'oxygen_unit': oxygenUnit,
      'burn_calories': burnCalories,
      'total_seconds': totalSeconds,
    };
  }

  PedometerResult copyWith({
    String? userId,
    DateTime? createdAt,
    String? id,
    List<LatLng>? positions,
    int? heartRate,
    int? oxygenUnit,
    double? burnCalories,
    int? totalSeconds,
  }) {
    return PedometerResult(
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      positions: positions ?? this.positions,
      heartRate: heartRate ?? this.heartRate,
      oxygenUnit: oxygenUnit ?? this.oxygenUnit,
      burnCalories: burnCalories ?? this.burnCalories,
      totalSeconds: totalSeconds ?? this.totalSeconds,
    );
  }

  double? calculateBurnCalories(
    UserModel user, {
    DateTime? referenceDate,
  }) {
    final int? hr = heartRate;
    final int? seconds = totalSeconds;
    if (hr == null || hr <= 0) return null;
    if (seconds == null || seconds <= 0) return null;

    final double weight = user.weight;
    if (weight <= 0) return null;

    final DateTime reference = referenceDate ?? createdAt;
    final int age = _calculateAge(user.birthday, reference);
    if (age <= 0) return null;

    final double durationMinutes = seconds / 60;
    if (durationMinutes <= 0) return null;

    final double base = user.isMale
        ? (-55.0969 + (0.6309 * hr) + (0.1988 * weight) + (0.2017 * age))
        : (-20.4022 + (0.4472 * hr) - (0.1263 * weight) + (0.074 * age));

    final double calories = base * (durationMinutes / 4.184);
    if (!calories.isFinite || calories <= 0) return null;
    return calories;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value is DateTime) {
      return value.toLocal();
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed.toLocal();
      }
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
    }
    return DateTime.now();
  }

  static List<LatLng> _parsePositions(dynamic value) {
    if (value is List) {
      return value
          .map((entry) {
            if (entry is Map<String, dynamic>) {
              return _parsePositionMap(entry);
            }
            if (entry is Map) {
              return _parsePositionMap(entry.cast<String, dynamic>());
            }
            return null;
          })
          .whereType<LatLng>()
          .toList();
    }
    return const <LatLng>[];
  }

  static LatLng? _parsePositionMap(Map<String, dynamic> map) {
    final lat = _parseDouble(map['lat']);
    final lng = _parseDouble(map['lng']);
    if (lat == null || lng == null) {
      return null;
    }
    return LatLng(lat, lng);
  }

  static int _calculateAge(DateTime birthday, DateTime reference) {
    int age = reference.year - birthday.year;
    final bool hasHadBirthdayThisYear = reference.month > birthday.month ||
        (reference.month == birthday.month && reference.day >= birthday.day);
    if (!hasHadBirthdayThisYear) {
      age -= 1;
    }
    if (age < 0) {
      return 0;
    }
    return age;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

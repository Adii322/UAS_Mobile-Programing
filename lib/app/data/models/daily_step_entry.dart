class DailyStepEntry {
  const DailyStepEntry({
    required this.step,
    required this.createdAt,
    this.userId,
  }) : assert(step >= 0, 'step must be non-negative');

  final int step;
  final DateTime createdAt;
  final String? userId;

  DailyStepEntry copyWith({
    int? step,
    DateTime? createdAt,
    String? userId,
  }) {
    return DailyStepEntry(
      step: step ?? this.step,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toStorageJson() {
    return <String, dynamic>{
      'step': step,
      'created_at': createdAt.toIso8601String(),
      if (userId != null) 'user_id': userId,
    };
  }

  static DailyStepEntry? fromStorageJson(dynamic value) {
    if (value is! Map) return null;
    final Map<dynamic, dynamic> map = value;

    final int? parsedStep = _parseInt(map['step']);
    final DateTime? parsedDate = _parseDateTime(map['created_at']);
    if (parsedStep == null || parsedDate == null) {
      return null;
    }

    final dynamic rawUserId = map['user_id'];
    final String? parsedUserId =
        rawUserId is String && rawUserId.isNotEmpty ? rawUserId : null;

    return DailyStepEntry(
      step: parsedStep,
      createdAt: parsedDate,
      userId: parsedUserId,
    );
  }

  Map<String, dynamic> toSupabasePayload({String? overrideUserId}) {
    return <String, dynamic>{
      'step': step,
      'created_at': createdAt.toUtc().toIso8601String(),
      'user_id': overrideUserId ?? userId,
    };
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      final DateTime? parsed = DateTime.tryParse(value);
      return parsed?.toLocal();
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value).toLocal();
    }
    return null;
  }
}

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:young_care/app/data/models/daily_step_entry.dart';

class DailyStepsRepository {
  DailyStepsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _tableName = 'daily_steps';

  Future<void> upsertDailySteps({
    required List<DailyStepEntry> entries,
    String? userId,
  }) async {
    if (entries.isEmpty) return;

    final String? resolvedUserId = userId;
    if (resolvedUserId == null || resolvedUserId.isEmpty) return;

    final List<DailyStepEntry> orderedEntries =
        List<DailyStepEntry>.from(entries)
          ..sort(
            (DailyStepEntry a, DailyStepEntry b) =>
                a.createdAt.compareTo(b.createdAt),
          );

    final Map<DateTime, Map<String, dynamic>?> dayCache =
        <DateTime, Map<String, dynamic>?>{};

    for (final DailyStepEntry entry in orderedEntries) {
      final DateTime dayKey = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );

      Map<String, dynamic>? currentRecord;
      if (dayCache.containsKey(dayKey)) {
        currentRecord = dayCache[dayKey];
      } else {
        currentRecord = await _findDailyRecord(
          userId: resolvedUserId,
          date: entry.createdAt,
        );
        dayCache[dayKey] = currentRecord;
      }

      if (currentRecord == null) {
        final Map<String, dynamic> payload =
            entry.toSupabasePayload(overrideUserId: resolvedUserId);
        final dynamic response =
            await _client.from(_tableName).insert(payload).select();
        dayCache[dayKey] = _firstMapOrNull(response);
        continue;
      }

      final int recordId = _parseInt(currentRecord['id']) ?? 0;
      if (recordId <= 0) {
        final Map<String, dynamic> payload =
            entry.toSupabasePayload(overrideUserId: resolvedUserId);
        final dynamic response =
            await _client.from(_tableName).insert(payload).select();
        dayCache[dayKey] = _firstMapOrNull(response);
        continue;
      }

      final int existingStep = _parseInt(currentRecord['step']) ?? 0;
      final int incomingStep = entry.step;
      final int nextStepValue =
          incomingStep >= existingStep ? incomingStep : existingStep + incomingStep;

      final Map<String, dynamic> updatePayload = <String, dynamic>{
        'step': nextStepValue,
        'created_at': entry.createdAt.toUtc().toIso8601String(),
      };

      final dynamic updateResponse = await _client
          .from(_tableName)
          .update(updatePayload)
          .eq('id', recordId)
          .select();

      dayCache[dayKey] = _firstMapOrNull(updateResponse) ??
          currentRecord
            ..['step'] = nextStepValue
            ..['created_at'] = entry.createdAt.toUtc().toIso8601String();
    }
  }

  Future<List<DailyStepEntry>> fetchEntries({
    required String userId,
    DateTime? start,
    DateTime? end,
    bool ascending = true,
  }) async {
    PostgrestFilterBuilder<dynamic> query =
        _client.from(_tableName).select().eq('user_id', userId);

    if (start != null) {
      query = query.gte('created_at', start.toUtc().toIso8601String());
    }

    if (end != null) {
      query = query.lt('created_at', end.toUtc().toIso8601String());
    }

    final dynamic response =
        await query.order('created_at', ascending: ascending);

    if (response is! List) {
      return const <DailyStepEntry>[];
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(DailyStepEntry.fromStorageJson)
        .whereType<DailyStepEntry>()
        .toList();
  }

  int calculateCumulativeSteps(Iterable<DailyStepEntry> entries) {
    final List<DailyStepEntry> sorted = List<DailyStepEntry>.from(entries)
      ..sort(
        (DailyStepEntry a, DailyStepEntry b) =>
            a.createdAt.compareTo(b.createdAt),
      );

    if (sorted.isEmpty) {
      return 0;
    }

    int total = sorted.first.step;

    for (final DailyStepEntry entry in sorted.skip(1)) {
      final int value = entry.step;
      if (total < value) {
        total = value;
      } else {
        total += value;
      }
    }

    return total;
  }

  Future<Map<String, dynamic>?> _findDailyRecord({
    required String userId,
    required DateTime date,
  }) async {
    final DateTime dayStart = DateTime.utc(date.year, date.month, date.day);
    final DateTime dayEnd = dayStart.add(const Duration(days: 1));

    final dynamic response = await _client
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .gte('created_at', dayStart.toIso8601String())
        .lt('created_at', dayEnd.toIso8601String())
        .order('created_at', ascending: false)
        .limit(1);

    return _firstMapOrNull(response);
  }

  Map<String, dynamic>? _firstMapOrNull(dynamic response) {
    if (response is Map<String, dynamic>) {
      return response;
    }
    if (response is List && response.isNotEmpty) {
      final dynamic first = response.first;
      if (first is Map<String, dynamic>) {
        return first;
      }
    }
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }
}

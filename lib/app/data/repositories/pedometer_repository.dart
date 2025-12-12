import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:young_care/app/data/models/pedometer_result.dart';

class PedometerRepository {
  PedometerRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String _tableName = 'pedometer_result';

  Future<List<PedometerResult>> fetchByUser({
    required String userId,
    DateTime? start,
    DateTime? end,
    int? limit,
    bool descending = true,
  }) async {
    PostgrestFilterBuilder<dynamic> query =
        _client.from(_tableName).select().eq('user_id', userId);

    if (start != null) {
      query = query.gte('created_at', _formatDate(start));
    }

    if (end != null) {
      query = query.lt('created_at', _formatDate(end));
    }

    final PostgrestTransformBuilder<dynamic> orderedQuery =
        query.order('created_at', ascending: !descending);

    final dynamic response = limit != null
        ? await orderedQuery.limit(limit)
        : await orderedQuery;

    if (response is! List) {
      return const <PedometerResult>[];
    }

    return response
        .whereType<Map<String, dynamic>>()
        .map(PedometerResult.fromMap)
        .toList();
  }

  Future<PedometerResult?> fetchLatestToday({
    required String userId,
    DateTime? reference,
  }) async {
    final DateTime base = reference ?? DateTime.now();
    final DateTime startOfDay = DateTime(base.year, base.month, base.day);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    final results = await fetchByUser(
      userId: userId,
      start: startOfDay,
      end: endOfDay,
      limit: 1,
      descending: true,
    );

    if (results.isEmpty) {
      return null;
    }
    return results.first;
  }

  Future<PedometerResult?> insertResult(PedometerResult result) async {
    final Map<String, dynamic> payload =
        Map<String, dynamic>.from(result.toMap());
    payload.remove('id');
    payload.removeWhere((_, dynamic value) => value == null);

    final dynamic response =
        await _client.from(_tableName).insert(payload).select();

    if (response is Map<String, dynamic>) {
      return PedometerResult.fromMap(response);
    }

    if (response is List && response.isNotEmpty) {
      final dynamic first = response.first;
      if (first is Map<String, dynamic>) {
        return PedometerResult.fromMap(first);
      }
    }

    return null;
  }

  String _formatDate(DateTime value) => value.toUtc().toIso8601String();
}

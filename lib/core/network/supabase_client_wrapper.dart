import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupabaseClientWrapper {
  Future<List<Map<String, dynamic>>> queryHabits({
    String? userId,
    int? limit,
    int? offset,
  });

  Future<Map<String, dynamic>?> insertHabit(Map<String, dynamic> habit);

  Future<void> updateHabit(String id, Map<String, dynamic> habit);

  Future<void> deleteHabit(String id);

  Future<List<Map<String, dynamic>>> queryHabitLogs({
    required String habitId,
    String? date,
    int? limit,
  });

  Future<Map<String, dynamic>?> insertHabitLog(Map<String, dynamic> log);

  Future<void> updateHabitLog(String habitId, String logId, Map<String, dynamic> log);
}

class SupabaseClientWrapperImpl implements SupabaseClientWrapper {
  final SupabaseClient client;

  SupabaseClientWrapperImpl({required this.client});

  @override
  Future<List<Map<String, dynamic>>> queryHabits({
    String? userId,
    int? limit,
    int? offset,
  }) async {
    if (userId == null) {
      if (offset != null && limit != null) {
        return client
            .from('habits')
            .select()
            .order('initial_date', ascending: false)
            .range(offset, offset + limit - 1);
      } else if (limit != null) {
        return client
            .from('habits')
            .select()
            .order('initial_date', ascending: false)
            .limit(limit);
      }
      return client
          .from('habits')
          .select()
          .order('initial_date', ascending: false);
    }

    if (offset != null && limit != null) {
      return client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('initial_date', ascending: false)
          .range(offset, offset + limit - 1);
    } else if (limit != null) {
      return client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('initial_date', ascending: false)
          .limit(limit);
    }
    return client
        .from('habits')
        .select()
        .eq('user_id', userId)
        .order('initial_date', ascending: false);
  }

  @override
  Future<Map<String, dynamic>?> insertHabit(Map<String, dynamic> habit) async {
    final response = await client
        .from('habits')
        .insert(habit)
        .select('id')
        .single();
    return response;
  }

  @override
  Future<void> updateHabit(String id, Map<String, dynamic> habit) async {
    await client.from('habits').update(habit).eq('id', id);
  }

  @override
  Future<void> deleteHabit(String id) async {
    await client.from('habits').delete().eq('id', id);
  }

  @override
  Future<List<Map<String, dynamic>>> queryHabitLogs({
    required String habitId,
    String? date,
    int? limit,
  }) async {
    var query = client.from('habit_logs').select().eq('habit_id', habitId);

    if (date != null) {
      query = query.eq('date', date);
    }

    if (limit != null) {
      return query.order('date', ascending: false).limit(limit);
    }

    return query.order('date', ascending: false);
  }

  @override
  Future<Map<String, dynamic>?> insertHabitLog(Map<String, dynamic> log) async {
    final response = await client
        .from('habit_logs')
        .insert(log)
        .select('id')
        .single();
    return response;
  }

  @override
  Future<void> updateHabitLog(
    String habitId,
    String logId,
    Map<String, dynamic> log,
  ) async {
    await client
        .from('habit_logs')
        .update(log)
        .eq('habit_id', habitId)
        .eq('id', logId);
  }
}
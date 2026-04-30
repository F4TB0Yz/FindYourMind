import 'dart:io';

import 'package:find_your_mind/core/error/exceptions.dart';
import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:find_your_mind/features/habits/data/models/habit_category_model.dart';
import 'package:find_your_mind/features/habits/data/models/habit_tracking_type_model.dart';
import 'package:find_your_mind/features/habits/data/models/item_habit_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HabitsRemoteDataSource {
  Future<List<HabitEntity>> getHabitsByUserId(String userId);

  Future<List<HabitEntity>> getHabitsByUserIdPaginated({
    required String userId,
    int limit = 10,
    int offset = 0,
  });

  Future<String?> createHabit(HabitEntity habit);

  Future<void> updateHabit(HabitEntity habit);

  Future<void> deleteHabit(String habitId);

  Future<String?> createHabitLog(HabitLog habitLog);

  Future<void> updateHabitLogValue({
    required String habitId,
    required String logId,
    required int value,
  });
}

class HabitsRemoteDataSourceImpl implements HabitsRemoteDataSource {
  final SupabaseClient client;

  HabitsRemoteDataSourceImpl({required this.client});

  @override
  Future<String?> createHabit(HabitEntity habit) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await client
          .from('habits')
          .insert({
            'id': habit.id,
            'title': habit.title,
            'user_id': habit.userId,
            'description': habit.description,
            'icon': habit.icon,
            'category': HabitCategoryModel.toStringValue(habit.category),
            'tracking_type': HabitTrackingTypeModel.toStringValue(
              habit.trackingType,
            ),
            'target_value': habit.targetValue,
            'initial_date': habit.initialDate,
            'created_at': now,
            'updated_at': now,
          })
          .select('id')
          .single();

      return response['id'] as String?;
    } on PostgrestException catch (e) {
      AppLogger.e('PostgrestException: ${e.message} - ${e.details} - ${e.hint}');
      throw ServerException('Error de base de datos: ${e.message}');
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } catch (e) {
      throw ServerException('Error al crear el hábito: ${e.toString()}');
    }
  }

  @override
  Future<void> updateHabit(HabitEntity habit) async {
    try {
      await client
          .from('habits')
          .update({
            'title': habit.title,
            'description': habit.description,
            'icon': habit.icon,
            'category': HabitCategoryModel.toStringValue(habit.category),
            'tracking_type': HabitTrackingTypeModel.toStringValue(
              habit.trackingType,
            ),
            'target_value': habit.targetValue,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', habit.id);
    } on PostgrestException catch (e) {
      throw ServerException('Error al actualizar: ${e.message}');
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } catch (e) {
      throw ServerException('Error al actualizar el hábito: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    try {
      await client.from('habits').delete().eq('id', habitId);
    } on PostgrestException catch (e) {
      throw ServerException('Error al eliminar: ${e.message}');
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } catch (e) {
      throw ServerException('Error al eliminar el hábito: ${e.toString()}');
    }
  }

  @override
  Future<List<HabitEntity>> getHabitsByUserId(String userId) async {
    try {
      final habitsResponse = await client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('initial_date', ascending: false);

      final List<Map<String, dynamic>> habitsWithLogs = [];

      for (final habit in habitsResponse) {
        final habitId = habit['id'];
        final logsResponse = await client
            .from('habit_logs')
            .select()
            .eq('habit_id', habitId);
        habit['logs'] = logsResponse;
        habitsWithLogs.add(habit);
      }

      return habitsWithLogs
          .map((habitJson) => ItemHabitModel.fromJson(habitJson).toEntity())
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Error al obtener hábitos: ${e.message}');
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } catch (e) {
      throw ServerException('Error al obtener hábitos: ${e.toString()}');
    }
  }

  @override
  Future<List<HabitEntity>> getHabitsByUserIdPaginated({
    required String userId,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final habitsResponse = await client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('initial_date', ascending: false)
          .range(offset, offset + limit - 1);

      final List<Map<String, dynamic>> habitsWithLogs = [];

      for (final habit in habitsResponse) {
        final habitId = habit['id'];
        final logsResponse = await client
            .from('habit_logs')
            .select()
            .eq('habit_id', habitId)
            .order('date', ascending: false)
            .limit(30);
        habit['logs'] = logsResponse;
        habitsWithLogs.add(habit);
      }

      return habitsWithLogs
          .map((habitJson) => ItemHabitModel.fromJson(habitJson).toEntity())
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException('Error al obtener hábitos: ${e.message}');
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } catch (e) {
      throw ServerException('Error al obtener hábitos: ${e.toString()}');
    }
  }

  @override
  Future<String?> createHabitLog(HabitLog habitLog) async {
    try {
      final existing = await client
          .from('habit_logs')
          .select('id')
          .eq('habit_id', habitLog.habitId)
          .eq('date', habitLog.date)
          .maybeSingle();

      if (existing != null) {
        final existingId = existing['id'] as String;
        AppLogger.w(
          '[REMOTE] Ya existe un log para ${habitLog.habitId} en ${habitLog.date}',
        );
        return existingId;
      }

      final response = await client
          .from('habit_logs')
          .insert({
            'id': habitLog.id,
            'habit_id': habitLog.habitId,
            'date': habitLog.date,
            'value': habitLog.value,
          })
          .select('id')
          .single();

      return response['id'] as String?;
    } on PostgrestException catch (e) {
      throw ServerException('Error al crear log: ${e.message}');
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } catch (e) {
      throw ServerException('Error al crear log: ${e.toString()}');
    }
  }

  @override
  Future<void> updateHabitLogValue({
    required String habitId,
    required String logId,
    required int value,
  }) async {
    try {
      await client
          .from('habit_logs')
          .update({'value': value})
          .eq('habit_id', habitId)
          .eq('id', logId);
    } on PostgrestException catch (e) {
      throw ServerException('Error al actualizar log: ${e.message}');
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } catch (e) {
      throw ServerException('Error al actualizar log: ${e.toString()}');
    }
  }
}

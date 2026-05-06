import 'dart:io';

import 'package:find_your_mind/core/error/exceptions.dart';
import 'package:find_your_mind/core/network/supabase_client_wrapper.dart';
import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:find_your_mind/features/habits/data/models/habit_category_model.dart';
import 'package:find_your_mind/features/habits/data/models/habit_tracking_type_model.dart';
import 'package:find_your_mind/features/habits/data/models/item_habit_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';

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
  final SupabaseClientWrapper client;

  HabitsRemoteDataSourceImpl({required this.client});

  @override
  Future<String?> createHabit(HabitEntity habit) async {
    try {
      final now = DateTime.now().toIso8601String();
      final response = await client.insertHabit({
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
      });

      return response?['id'] as String?;
    } on FormatException catch (e) {
      AppLogger.e('FormatException: ${e.message}');
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
      await client.updateHabit(habit.id, {
        'title': habit.title,
        'description': habit.description,
        'icon': habit.icon,
        'category': HabitCategoryModel.toStringValue(habit.category),
        'tracking_type': HabitTrackingTypeModel.toStringValue(
          habit.trackingType,
        ),
        'target_value': habit.targetValue,
        'color': habit.color,
        'unit': habit.unit,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } on FormatException catch (e) {
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
      await client.deleteHabit(habitId);
    } on FormatException catch (e) {
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
      final habitsResponse = await client.queryHabits(userId: userId);

      final List<Map<String, dynamic>> habitsWithLogs = [];

      for (final habit in habitsResponse) {
        final habitId = habit['id'];
        final logsResponse = await client.queryHabitLogs(habitId: habitId);
        final habitWithLogs = Map<String, dynamic>.from(habit);
        habitWithLogs['logs'] = logsResponse;
        habitsWithLogs.add(habitWithLogs);
      }

      return habitsWithLogs
          .map((habitJson) => ItemHabitModel.fromJson(habitJson).toEntity())
          .toList();
    } on FormatException catch (e) {
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
      final habitsResponse = await client.queryHabits(
        userId: userId,
        limit: limit,
        offset: offset,
      );

      final List<Map<String, dynamic>> habitsWithLogs = [];

      for (final habit in habitsResponse) {
        final habitId = habit['id'];
        final logsResponse = await client.queryHabitLogs(
          habitId: habitId,
          limit: 30,
        );
        final habitWithLogs = Map<String, dynamic>.from(habit);
        habitWithLogs['logs'] = logsResponse;
        habitsWithLogs.add(habitWithLogs);
      }

      return habitsWithLogs
          .map((habitJson) => ItemHabitModel.fromJson(habitJson).toEntity())
          .toList();
    } on FormatException catch (e) {
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
      final existing = await client.queryHabitLogs(
        habitId: habitLog.habitId,
        date: habitLog.date,
      );

      if (existing.isNotEmpty) {
        final existingId = existing.first['id'] as String;
        AppLogger.w(
          '[REMOTE] Ya existe un log para ${habitLog.habitId} en ${habitLog.date}',
        );
        return existingId;
      }

      final response = await client.insertHabitLog({
        'id': habitLog.id,
        'habit_id': habitLog.habitId,
        'date': habitLog.date,
        'value': habitLog.value,
      });

      return response?['id'] as String?;
    } on FormatException catch (e) {
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
      await client.updateHabitLog(habitId, logId, {'value': value});
    } on FormatException catch (e) {
      throw ServerException('Error al actualizar log: ${e.message}');
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } catch (e) {
      throw ServerException('Error al actualizar log: ${e.toString()}');
    }
  }
}

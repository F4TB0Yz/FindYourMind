import 'package:find_your_mind/core/config/database_helper.dart';
import 'package:find_your_mind/core/error/exceptions.dart';
import 'package:find_your_mind/features/habits/data/models/item_habit_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

abstract class HabitsLocalDatasource {
  // Users Habits
  Future<List<HabitEntity>> getHabitsByUserId(String userId);

  Future<List<HabitEntity>> getHabitsByUserIdPaginated({
    required String userId,
    int limit = 10,
    int offset = 0,
  });

  // Habits
  Future<String?> createHabit(HabitEntity habit);

  Future<void> updateHabit(HabitEntity habit);

  Future<void> deleteHabit(String habitId);

  // Habit Progress
  Future<String?> createHabitProgress(HabitProgress habitProgress);

  Future<void> deleteHabitProgress(String habitId);

  Future<void> updateHabitCounter({
    required String habitId,
    required String progressId,
    required int newCounter,
  });

  // Obtener datos completos de un progreso
  Future<HabitProgress?> getHabitProgressById(String progressId);

  // Métodos auxiliares para sincronización
  Future<void> deleteHabitPendingSync(String habitId);

  Future<void> clearAllHabits(String userId);

  Future<void> saveHabits(List<HabitEntity> habits);
}

class HabitsLocalDatasourceImpl implements HabitsLocalDatasource {
  final DatabaseHelper databaseHelper;

  HabitsLocalDatasourceImpl({required this.databaseHelper});

  @override
  Future<List<HabitEntity>> getHabitsByUserId(String userId) async {
    try {
      print('🔍 [LOCAL_DS] getHabitsByUserId - Obteniendo base de datos...');
      final db = await databaseHelper.database;

      print(
        '🔍 [LOCAL_DS] getHabitsByUserId - Ejecutando query para userId: $userId',
      );
      final List<Map<String, dynamic>> habitMaps = await db.query(
        'habits',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'initial_date DESC',
      );

      print(
        '✅ [LOCAL_DS] getHabitsByUserId - Query exitosa: ${habitMaps.length} hábitos',
      );

      List<Map<String, dynamic>> habitsWithProgress = [];

      for (var habitMap in habitMaps) {
        // Crear una copia mutable del map
        final mutableHabitMap = Map<String, dynamic>.from(habitMap);
        final habitId = mutableHabitMap['id'] as String;

        final progressResponse = await db.query(
          'habit_progress',
          where: 'habit_id = ?',
          whereArgs: [habitId],
          orderBy: 'date DESC',
        );

        mutableHabitMap['progress'] = progressResponse;
        habitsWithProgress.add(mutableHabitMap);
      }

      return habitsWithProgress.map((habitJson) {
        return ItemHabitModel.fromJson(habitJson).toEntity();
      }).toList();
    } on DatabaseException catch (e) {
      print(
        '❌ [LOCAL_DS] getHabitsByUserId - DatabaseException: ${e.toString()}',
      );
      throw CacheException('Error al obtener hábitos: ${e.toString()}');
    } catch (e) {
      print('❌ [LOCAL_DS] getHabitsByUserId - Error: ${e.toString()}');
      print('❌ [LOCAL_DS] getHabitsByUserId - Tipo: ${e.runtimeType}');
      throw CacheException('Error al obtener hábitos: ${e.toString()}');
    }
  }

  @override
  Future<List<HabitEntity>> getHabitsByUserIdPaginated({
    required String userId,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      print('🔍 [LOCAL_DS] Obteniendo base de datos...');
      final db = await databaseHelper.database;

      print(
        '🔍 [LOCAL_DS] Ejecutando query - userId: $userId, limit: $limit, offset: $offset',
      );
      final List<Map<String, dynamic>> habitMaps = await db.query(
        'habits',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'initial_date DESC',
        limit: limit,
        offset: offset,
      );

      print(
        '✅ [LOCAL_DS] Query exitosa - ${habitMaps.length} registros encontrados',
      );

      List<Map<String, dynamic>> habitsWithProgress = [];

      print(
        '🔄 [LOCAL_DS] Iterando sobre ${habitMaps.length} hábitos para obtener progreso...',
      );
      for (var habitMap in habitMaps) {
        // Crear una copia mutable del map
        final mutableHabitMap = Map<String, dynamic>.from(habitMap);
        final habitId = mutableHabitMap['id'] as String;
        print('🔍 [LOCAL_DS] Obteniendo progreso para hábito: $habitId');

        try {
          // Obtener solo los últimos 30 días de progreso para optimizar
          final progressResponse = await db.query(
            'habit_progress',
            where: 'habit_id = ?',
            whereArgs: [habitId],
            orderBy: 'date DESC',
            limit: 30,
          );

          print(
            '✅ [LOCAL_DS] Progreso obtenido: ${progressResponse.length} registros',
          );
          mutableHabitMap['progress'] = progressResponse;
          habitsWithProgress.add(mutableHabitMap);
        } catch (e) {
          print('❌ [LOCAL_DS] Error obteniendo progreso para $habitId: $e');
          // Si falla obtener el progreso, agregar el hábito sin progreso
          mutableHabitMap['progress'] = [];
          habitsWithProgress.add(mutableHabitMap);
        }
      }

      print(
        '✅ [LOCAL_DS] Procesados ${habitsWithProgress.length} hábitos con progreso',
      );

      return habitsWithProgress.map((habitJson) {
        return ItemHabitModel.fromJson(habitJson).toEntity();
      }).toList();
    } on DatabaseException catch (e) {
      print('❌ [LOCAL_DS] DatabaseException: ${e.toString()}');
      throw CacheException('Error al obtener hábitos: ${e.toString()}');
    } catch (e) {
      print('❌ [LOCAL_DS] Error genérico: ${e.toString()}');
      print('❌ [LOCAL_DS] Tipo de error: ${e.runtimeType}');
      throw CacheException('Error al obtener hábitos: ${e.toString()}');
    }
  }

  @override
  Future<String?> createHabit(HabitEntity habit) async {
    try {
      final db = await databaseHelper.database;

      // Usar el ID que viene en el hábito (generado previamente)
      // Si no tiene ID, generar uno nuevo
      final String habitId = habit.id.isNotEmpty ? habit.id : const Uuid().v4();

      await db.insert('habits', {
        'id': habitId,
        'user_id': habit.userId,
        'title': habit.title,
        'description': habit.description,
        'icon': habit.icon,
        'type': habit.type.name,
        'daily_goal': habit.dailyGoal,
        'initial_date': habit.initialDate,
        'created_at': DateTime.now().toIso8601String(),
        'synced': 0, // Marcar como no sincronizado
        'updated_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      return habitId;
    } on DatabaseException catch (e) {
      developer.log(
        'Error al crear hábito',
        name: 'HabitsLocalDatasourceImpl.createHabit',
        error: e,
      );
      throw CacheException('Error al crear hábito: ${e.toString()}');
    } catch (e) {
      developer.log(
        'Error al crear hábito',
        name: 'HabitsLocalDatasourceImpl.createHabit',
        error: e,
      );
      throw CacheException('Error al crear hábito: ${e.toString()}');
    }
  }

  @override
  Future<void> updateHabit(HabitEntity habit) async {
    try {
      final db = await databaseHelper.database;

      // Obtener la fecha actual en formato YYYY-MM-DD
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Usar transacción para asegurar consistencia
      await db.transaction((txn) async {
        // 1. Actualizar el hábito
        await txn.update(
          'habits',
          {
            'title': habit.title,
            'description': habit.description,
            'icon': habit.icon,
            'type': habit.type.name,
            'daily_goal': habit.dailyGoal,
            'synced': 0, // Marcar como no sincronizado
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [habit.id],
        );

        // 2. Actualizar el daily_goal SOLO en los registros de progreso desde HOY en adelante
        final updatedProgressCount = await txn.update(
          'habit_progress',
          {
            'daily_goal': habit.dailyGoal,
            'synced': 0, // Marcar como no sincronizado
          },
          where: 'habit_id = ? AND date >= ?',
          whereArgs: [habit.id, todayString],
        );

        if (kDebugMode) {
          print('✅ Hábito actualizado: ${habit.id}');
          print('✅ daily_goal sincronizado en $updatedProgressCount registros de progreso desde $todayString');
        }
      });
    } on DatabaseException catch (e) {
      throw CacheException('Error al actualizar hábito: ${e.toString()}');
    } catch (e) {
      throw CacheException('Error al actualizar hábito: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    try {
      final db = await databaseHelper.database;

      // SQLite eliminará automáticamente el progreso por la foreign key en cascada
      await db.delete('habits', where: 'id = ?', whereArgs: [habitId]);
    } on DatabaseException catch (e) {
      throw CacheException('Error al eliminar hábito: ${e.toString()}');
    } catch (e) {
      throw CacheException('Error al eliminar hábito: ${e.toString()}');
    }
  }

  @override
  Future<String?> createHabitProgress(HabitProgress habitProgress) async {
    try {
      final db = await databaseHelper.database;

      // 🔍 VERIFICAR SI YA EXISTE UN PROGRESO PARA ESTE HÁBITO EN ESTA FECHA
      final existing = await db.query(
        'habit_progress',
        where: 'habit_id = ? AND date = ?',
        whereArgs: [habitProgress.habitId, habitProgress.date],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        // ⚠️ Ya existe un progreso para este día - retornar el ID existente
        final existingId = existing.first['id'] as String;
        if (kDebugMode) {
          print('⚠️ Ya existe un progreso para ${habitProgress.habitId} en ${habitProgress.date}');
          print('   Retornando ID existente: $existingId');
        }
        return existingId;
      }

      // Usar el ID que viene en el progreso (generado previamente)
      // Si no tiene ID, generar uno nuevo
      final String progressId = habitProgress.id.isNotEmpty 
          ? habitProgress.id 
          : const Uuid().v4();

      await db.insert('habit_progress', {
        'id': progressId,
        'habit_id': habitProgress.habitId,
        'date': habitProgress.date,
        'daily_counter': habitProgress.dailyCounter,
        'daily_goal': habitProgress.dailyGoal,
        'synced': 0, // Marcar como no sincronizado
      });

      if (kDebugMode) {
        print('✅ Nuevo progreso creado: $progressId para ${habitProgress.date}');
      }

      return progressId;
    } on DatabaseException catch (e) {
      throw CacheException('Error al crear progreso: ${e.toString()}');
    } catch (e) {
      throw CacheException('Error al crear progreso: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHabitProgress(String habitId) async {
    try {
      final db = await databaseHelper.database;

      await db.delete(
        'habit_progress',
        where: 'habit_id = ?',
        whereArgs: [habitId],
      );
    } on DatabaseException catch (e) {
      throw CacheException(
        'Error al eliminar progresos del hábito: ${e.toString()}',
      );
    } catch (e) {
      throw CacheException(
        'Error al eliminar progresos del hábito: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateHabitCounter({
    required String habitId,
    required String progressId,
    required int newCounter,
  }) async {
    try {
      final db = await databaseHelper.database;

      await db.update(
        'habit_progress',
        {
          'daily_counter': newCounter,
          'synced': 0, // Marcar como no sincronizado
        },
        where: 'habit_id = ? AND id = ?',
        whereArgs: [habitId, progressId],
      );
    } on DatabaseException catch (e) {
      throw CacheException('Error al actualizar progreso: ${e.toString()}');
    } catch (e) {
      throw CacheException('Error al actualizar progreso: ${e.toString()}');
    }
  }

  @override
  Future<HabitProgress?> getHabitProgressById(String progressId) async {
    try {
      final db = await databaseHelper.database;

      final List<Map<String, dynamic>> progressData = await db.query(
        'habit_progress',
        where: 'id = ?',
        whereArgs: [progressId],
      );

      if (progressData.isEmpty) {
        return null;
      }

      final data = progressData.first;
      return HabitProgress(
        id: data['id'] as String,
        habitId: data['habit_id'] as String,
        date: data['date'] as String,
        dailyGoal: data['daily_goal'] as int,
        dailyCounter: data['daily_counter'] as int,
      );
    } on DatabaseException catch (e) {
      throw CacheException('Error al obtener progreso: ${e.toString()}');
    } catch (e) {
      throw CacheException('Error al obtener progreso: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHabitPendingSync(String habitId) async {
    try {
      final db = await databaseHelper.database;

      await db.delete(
        'pending_sync',
        where: 'entity_id = ? AND entity_type = ?',
        whereArgs: [habitId, 'habit'],
      );
    } on DatabaseException catch (e) {
      throw CacheException(
        'Error al eliminar sincronización pendiente: ${e.toString()}',
      );
    } catch (e) {
      throw CacheException(
        'Error al eliminar sincronización pendiente: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearAllHabits(String userId) async {
    try {
      final db = await databaseHelper.database;

      // SQLite eliminará automáticamente el progreso por la foreign key en cascada
      await db.delete('habits', where: 'user_id = ?', whereArgs: [userId]);
    } on DatabaseException catch (e) {
      throw CacheException('Error al limpiar hábitos: ${e.toString()}');
    } catch (e) {
      throw CacheException('Error al limpiar hábitos: ${e.toString()}');
    }
  }

  @override
  Future<void> saveHabits(List<HabitEntity> habits) async {
    try {
      final db = await databaseHelper.database;

      await db.transaction((txn) async {
        for (var habit in habits) {
          await txn.insert('habits', {
            'id': habit.id,
            'user_id': habit.userId,
            'title': habit.title,
            'description': habit.description,
            'icon': habit.icon,
            'type': habit.type.name,
            'daily_goal': habit.dailyGoal,
            'initial_date': habit.initialDate,
            'created_at': DateTime.now().toIso8601String(),
            'synced': 1, // Marcar como sincronizado (viene del servidor)
            'updated_at': DateTime.now().toIso8601String(),
          }, conflictAlgorithm: ConflictAlgorithm.replace);

          // Guardar el progreso asociado
          for (var progress in habit.progress) {
            await txn.insert('habit_progress', {
              'id': progress.id,
              'habit_id': progress.habitId,
              'date': progress.date,
              'daily_goal': progress.dailyGoal,
              'daily_counter': progress.dailyCounter,
              'synced': 1, // Marcar como sincronizado (viene del servidor)
            }, conflictAlgorithm: ConflictAlgorithm.replace);
          }
        }
      });
    } on DatabaseException catch (e) {
      throw CacheException('Error al guardar hábitos: ${e.toString()}');
    } catch (e) {
      throw CacheException('Error al guardar hábitos: ${e.toString()}');
    }
  }
}

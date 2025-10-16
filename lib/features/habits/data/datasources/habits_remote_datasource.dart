import 'dart:io';

import 'package:find_your_mind/core/error/exceptions.dart';
import 'package:find_your_mind/features/habits/data/models/item_habit_model.dart';
import 'package:find_your_mind/features/habits/data/models/type_habit_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class HabitsRemoteDataSource {
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

  Future<void> incrementHabitProgress({
    required String habitId,
    required String progressId,
    required int newCounter,
  });
}

class HabitsRemoteDataSourceImpl implements HabitsRemoteDataSource {
  final SupabaseClient client;

  HabitsRemoteDataSourceImpl({ required this.client });
  
  @override
  Future<String?> createHabit(HabitEntity habit) async {
    try {
      final response = await client
        .from('habits')
        .insert({
          'title': habit.title,
          'user_id': habit.userId,
          'description': habit.description,
          'icon': habit.icon,
          'type': TypeHabitModel.typeToString(habit.type),
          'daily_goal': habit.dailyGoal,
          'initial_date': habit.initialDate,
        })
        .select('id')
        .single();

        if (response['id'] != null) {
          return response['id'] as String?;
        }

        return response['id'] as String?;
      
    } on PostgrestException catch (e){
      throw ServerException('Error de base de datos ${e.message}');
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } catch (e) {
      throw ServerException('Error al crear el hábito: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateHabit(HabitEntity habit) async {
    final String type = TypeHabitModel.typeToString(habit.type);

    try {
      await client
        .from('habits')
        .update({
          'title': habit.title,
          'description': habit.description,
          'icon': habit.icon,
          'type': type,
          'daily_goal': habit.dailyGoal,
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
      await client
        .from('habits')
        .delete()
        .eq('id', habitId);
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
      
      // Para cada hábito, obtener sus progresos y agregarlos al diccionario
      List<Map<String, dynamic>> habitsWithProgress = [];
    
      for (var habit in habitsResponse) {
        final habitId = habit['id'];
        final progressResponse = await client
          .from('habit_progress')
          .select()
          .eq('habit_id', habitId);
        habit['progress'] = progressResponse;
        habitsWithProgress.add(habit);
      }

      return habitsWithProgress.map((habitJson) {
        return ItemHabitModel.fromJson(habitJson).toEntity();
      }).toList();
          
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
    int offset = 0
  }) async {
    try {
      final habitsResponse = await client
          .from('habits')
          .select()
          .eq('user_id', userId)
          .order('initial_date', ascending: false)
          .range(offset, offset + limit - 1);

      // Para cada hábito, obtener sus progresos
      List<Map<String, dynamic>> habitsWithProgress = [];

      for (var habit in habitsResponse) {
        final habitId = habit['id'];
        // Obtener solo los últimos 30 días de progreso para optimizar
        final progressResponse = await client
          .from('habit_progress')
          .select()
          .eq('habit_id', habitId)
          .order('date', ascending: false)
          .limit(30);
        
        habit['progress'] = progressResponse;
        habitsWithProgress.add(habit);
      }

      return habitsWithProgress.map((habitJson) {
        return ItemHabitModel.fromJson(habitJson).toEntity();
      }).toList();
    } on PostgrestException catch (e) {
      throw ServerException('Error al obtener hábitos: ${e.message}');
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } catch (e) {
      throw ServerException('Error al obtener hábitos: ${e.toString()}');
    }
  }

  @override
  Future<String?> createHabitProgress(HabitProgress habitProgress) async {
    try {
      final response = await client
          .from('habit_progress')
          .insert({
            'habit_id': habitProgress.habitId,
            'date': habitProgress.date,
            'daily_counter': habitProgress.dailyCounter,
            'daily_goal': habitProgress.dailyGoal,
          })
          .select('id')
          .single();
      
      return response['id'] as String?;
      
    } on PostgrestException catch (e) {
      throw ServerException('Error al crear progreso: ${e.message}');
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } catch (e) {
      throw ServerException('Error al crear progreso: ${e.toString()}');
    }
  }
  
  @override
  Future<void> incrementHabitProgress({
    required String habitId, 
    required String progressId, 
    required int newCounter
    }) async {
    try {
      await client
        .from('habit_progress')
        .update({'daily_counter': newCounter})
        .eq('habit_id', habitId)
        .eq('id', progressId);
    } on PostgrestException catch (e) {
      throw ServerException('Error al actualizar progreso: ${e.message}');
    } on SocketException {
      throw NetworkException('Sin conexión a internet');
    } catch (e) {
      throw ServerException('Error al actualizar progreso: ${e.toString()}');
    }
  }
}

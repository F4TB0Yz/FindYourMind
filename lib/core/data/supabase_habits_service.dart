import 'package:find_your_mind/features/habits/data/models/item_habit_model.dart';
import 'package:find_your_mind/features/habits/data/models/type_habit_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/habits/domain/entities/habit_entity.dart';

class SupabaseHabitsService {
  final SupabaseClient client = Supabase.instance.client;

  Future<String?> saveHabit(HabitEntity habit) async {
    final response = await client.from('habits').insert({
      'title': habit.title,
      'user_id': habit.userId,
      'description': habit.description,
      'icon': habit.icon,
      'type': TypeHabitModel().typeToString(habit.type),
      'daily_goal': habit.dailyGoal,
      'initial_date': habit.initialDate,
    }).select('id').single();
    if (response['id'] != null) {
      return response['id'] as String;
    }
    return null;
  }

  Future<String?> createHabitProgress({
    required String habitId,
    required String date,
    required int dailyCounter,
    required int dailyGoal
  }) async {
    try {
      final Map<String, dynamic> data = {
        'habit_id': habitId,
        'date': date,
        'daily_counter': dailyCounter,
        'daily_goal': dailyGoal
      };
      
      final response = await client
          .from('habit_progress')
          .insert(data)
          .select('id')
          .single();
      
      return response['id'];
    } catch (error) {
      print('Error al crear progreso de hábito: $error');
      return null;
    }
  }

  Future<String> getIdUserByEmail(String email) async {
    final response = await client
      .from('users')
      .select('id')
      .eq('correo', email)
      .single();

    if (response['id'] != null) {
      return response['id'] as String;
    } else {
      throw Exception('User not found');
    }
  }

  Future<List<HabitEntity>> getHabitsByEmail(String email) async {
    final userId = await getIdUserByEmail(email);

    // Obtener los hábitos del usuario
    final habitsResponse = await client
      .from('habits')
      .select()
      .eq('user_id', userId);

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
  }

  Future<void> updateHabitProgress(String habitId, String progressId, int newCounter) async {
    print('Updating habit progress: habitId=$habitId, progressId=$progressId, newCounter=$newCounter');
    
    final response = await client.from('habit_progress')
      .update({'daily_counter': newCounter})
      .eq('habit_id', habitId)
      .eq('id', progressId);
    
    print('Habit progress update response: $response');
    print('Habit progress updated successfully');
  }
}
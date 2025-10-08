import 'package:find_your_mind/features/habits/data/models/item_habit_model.dart';
import 'package:find_your_mind/features/habits/data/models/type_habit_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/habits/domain/entities/habit_entity.dart';

class SupabaseHabitsService {
  final SupabaseClient client = Supabase.instance.client;

  Future<String?> saveHabit(HabitEntity habit) async {
    try {
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
    } catch (e) {
      throw Exception('Error al guardar el hábito en el servicio.');
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
      throw Exception('Error al crear progreso de hábito');
    }
  }

  Future<String> getIdUserByEmail(String email) async {
    try {
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
    } catch (e) {
      throw Exception('Error al obtener el ID del usuario');
    }
  }

  Future<List<HabitEntity>> getHabitsByEmail(String email) async {
    try {
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
    } catch (e) {
      throw Exception('Error al obtener los hábitos del usuario');
    }
  }

  /// Obtiene hábitos paginados de un usuario por email
  /// [email] Email del usuario
  /// [limit] Cantidad de hábitos a cargar por página
  /// [offset] Desplazamiento para la paginación
  Future<List<HabitEntity>> getHabitsByEmailPaginated({
    required String email,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final userId = await getIdUserByEmail(email);

      // Obtener hábitos paginados, ordenados por fecha inicial (más recientes primero)
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
    } catch (e) {
      throw Exception('Error al obtener los hábitos del usuario: ${e.toString()}');
    }
  }

  Future<void> updateHabitProgress(String habitId, String progressId, int newCounter) async {
    try {
      await client.from('habit_progress')
        .update({'daily_counter': newCounter})
        .eq('habit_id', habitId)
        .eq('id', progressId); 
    } catch (e) {
      throw Exception('Error al actualizar el progreso del hábito');
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      // Primero eliminar todos los progresos asociados al hábito
      final progressResult = await client
        .from('habit_progress')
        .delete()
        .eq('habit_id', habitId)
        .select();
      
      print('Progresos eliminados: ${progressResult.length}');
      
      // Luego eliminar el hábito
      final habitResult = await client
        .from('habits')
        .delete()
        .eq('id', habitId)
        .select();
      
      print('Hábito eliminado: $habitResult');
      
      if (habitResult.isEmpty) {
        throw Exception('No se encontró el hábito con ID: $habitId');
      }
      
      print('Habit deleted successfully');
    } catch (e) {
      print('Error detallado al eliminar el hábito: $e');
      throw Exception('Error al eliminar el hábito: ${e.toString()}');
    }
  }

  /// Actualiza los datos de un hábito existente
  /// 
  /// Parámetros:
  /// - [habit]: El hábito con los datos actualizados
  /// 
  /// Actualiza: título, descripción, icono y meta diaria
  Future<void> updateHabit(HabitEntity habit) async {  
    try {
      await client.from('habits')
      .update({
        'title': habit.title,
        'description': habit.description,
        'icon': habit.icon,
        'daily_goal': habit.dailyGoal,
      })
      .eq('id', habit.id);
      print('Habit updated successfully');
  } catch (e) {
    throw Exception('Error al actualizar el hábito');
  }
}

  
}
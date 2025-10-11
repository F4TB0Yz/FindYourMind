import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';

/// Repositorio abstracto para las operaciones de hábitos
/// Define el contrato que debe cumplir la implementación
abstract class HabitRepository {
  Future<List<HabitEntity>> getHabitsByEmail(String email);
  
  /// Obtiene hábitos paginados de un usuario por email
  Future<List<HabitEntity>> getHabitsByEmailPaginated({
    required String email,
    int limit = 10,
    int offset = 0,
  });
  
  /// Guarda un nuevo hábito
  Future<String?> saveHabit(HabitEntity habit);
  
  /// Actualiza un hábito existente
  Future<void> updateHabit(HabitEntity habit);
  
  /// Actualiza el progreso de un hábito
  Future<void> updateHabitProgress(
    String habitId, 
    String progressId, 
    int newCounter
  );
  
  /// Crea un nuevo registro de progreso para un hábito
  Future<String?> createHabitProgress({
    required String habitId,
    required String date,
    required int dailyCounter,
    required int dailyGoal,
  });
  
  /// Elimina un hábito y todo su progreso asociado
  Future<void> deleteHabit(String habitId);
}

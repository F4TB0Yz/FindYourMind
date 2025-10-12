import 'package:find_your_mind/core/data/supabase_habits_service.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';

/// Implementación del repositorio de hábitos
/// Utiliza SupabaseHabitsService para las operaciones de datos
class HabitRepositoryImpl implements HabitRepository {
  final SupabaseHabitsService _habitsService;

  HabitRepositoryImpl(this._habitsService);

  @override
  Future<List<HabitEntity>> getHabitsByEmail(String email) async {
    return await _habitsService.getHabitsByEmail(email);
  }

  @override
  Future<List<HabitEntity>> getHabitsByEmailPaginated({
    required String email,
    int limit = 10,
    int offset = 0,
  }) async {
    return await _habitsService.getHabitsByEmailPaginated(
      email: email,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<String?> saveHabit(HabitEntity habit) async {
    return await _habitsService.saveHabit(habit);
  }

  @override
  Future<void> updateHabit(HabitEntity habit) async {
    return await _habitsService.updateHabit(habit);
  }

  @override
  Future<void> updateHabitProgress(
    String habitId,
    String progressId,
    int newCounter,
  ) async {
    return await _habitsService.updateHabitProgress(
      habitId,
      progressId,
      newCounter,
    );
  }

  @override
  Future<String?> createHabitProgress({
    required String habitId,
    required String date,
    required int dailyCounter,
    required int dailyGoal,
  }) async {
    return await _habitsService.createHabitProgress(
      habitId: habitId,
      date: date,
      dailyCounter: dailyCounter,
      dailyGoal: dailyGoal,
    );
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    try {
      await _habitsService.deleteHabit(habitId);
    } catch (e) {
      throw Exception('Error al eliminar el hábito');
    }
  }
}

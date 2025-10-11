import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';

/// Caso de uso para actualizar un hábito
/// Encapsula la lógica de negocio para la actualización de hábitos
class UpdateHabitUseCase {
  final HabitRepository _repository;

  UpdateHabitUseCase(this._repository);

  /// Ejecuta la actualización del hábito
  /// 
  /// Parámetros:
  /// - [habit]: El hábito con los datos actualizados
  /// 
  /// Lanza una excepción si:
  /// - El título está vacío
  /// - El dailyGoal es menor a 1
  Future<void> execute(HabitEntity habit) async {
    if (habit.title.trim().isEmpty) {
      throw Exception('El título del hábito no puede estar vacío');
    }

    if (habit.dailyGoal < 1) {
      throw Exception('La meta diaria debe ser al menos 1');
    }

    // Ejecutar la actualización
    await _repository.updateHabit(habit);
  }
}

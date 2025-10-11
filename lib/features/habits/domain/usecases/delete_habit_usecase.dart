import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';

/// Caso de uso para eliminar un hábito
/// Valida y ejecuta la lógica de negocio para eliminar un hábito
class DeleteHabitUseCase {
  final HabitRepository repository;

  DeleteHabitUseCase(this.repository);

  /// Ejecuta la eliminación del hábito
  /// 
  /// [habitId] ID del hábito a eliminar
  /// 
  /// Lanza [ArgumentError] si el habitId está vacío
  Future<void> execute(String habitId) async {
    if (habitId.isEmpty) {
      throw ArgumentError('El ID del hábito no puede estar vacío');
    }
    
    // Ejecutar eliminación
    await repository.deleteHabit(habitId);
  }
}

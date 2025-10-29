import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';

/// Caso de uso para actualizar un hábito
/// 
/// Encapsula la lógica de negocio para:
/// - Validar los datos del hábito antes de actualizarlo
/// - Ejecutar la actualización en el repositorio
class UpdateHabitUseCase {
  final HabitRepository _repository;

  UpdateHabitUseCase(this._repository);

  /// Ejecuta la actualización del hábito
  /// 
  /// Parámetros:
  /// - [habit]: El hábito con los datos actualizados
  /// 
  /// Retorna:
  /// - [Right(void)]: Si la actualización fue exitosa
  /// - [Left(Failure)]: Si ocurre un error
  /// 
  /// Lanza validaciones si:
  /// - El ID está vacío
  /// - El título está vacío
  /// - La meta diaria es menor a 1
  /// - El icono está vacío
  Future<Either<Failure, void>> execute({
    required HabitEntity habit,
  }) async {
    // Validación: ID no vacío
    if (habit.id.trim().isEmpty) {
      return Left(
        ValidationFailure('El ID del hábito no puede estar vacío'),
      );
    }

    // Validación: Título no vacío
    if (habit.title.trim().isEmpty) {
      return Left(
        ValidationFailure('El título del hábito no puede estar vacío'),
      );
    }

    // Validación: Meta diaria válida
    if (habit.dailyGoal < 1) {
      return Left(
        ValidationFailure('La meta diaria debe ser al menos 1'),
      );
    }

    // Validación: Icono no vacío
    if (habit.icon.isEmpty) {
      return Left(
        ValidationFailure('El icono del hábito no puede estar vacío'),
      );
    }

    // Ejecutar la actualización
    return await _repository.updateHabit(habit);
  }
}

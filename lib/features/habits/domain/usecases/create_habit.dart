import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';

/// Caso de uso para crear un hábito
/// 
/// Encapsula la lógica de negocio para:
/// - Validar los datos del hábito antes de crearlo
/// - Ejecutar la creación en el repositorio
class CreateHabitUseCase {
  final HabitRepository _repository;

  CreateHabitUseCase(this._repository);

  /// Ejecuta la creación del hábito
  /// 
  /// Parámetros:
  /// - [habit]: El hábito a crear
  /// 
  /// Retorna:
  /// - [Right(String)]: El ID del hábito creado
  /// - [Left(Failure)]: Si ocurre un error
  /// 
  /// Lanza validaciones si:
  /// - El título está vacío
  /// - La meta diaria es menor a 1
  /// - El icono está vacío
  Future<Either<Failure, String?>> execute({
    required HabitEntity habit,
  }) async {
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

    // Ejecutar creación
    return await _repository.createHabit(habit);
  }
}

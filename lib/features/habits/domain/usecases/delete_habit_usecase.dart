import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';

/// Caso de uso para eliminar un hábito
/// 
/// Encapsula la lógica de negocio para:
/// - Validar que el ID del hábito es válido
/// - Ejecutar la eliminación en el repositorio
class DeleteHabitUseCase {
  final HabitRepository _repository;

  DeleteHabitUseCase(this._repository);

  /// Ejecuta la eliminación del hábito
  /// 
  /// Parámetros:
  /// - [habitId]: ID del hábito a eliminar
  /// 
  /// Retorna:
  /// - [Right(void)]: Si la eliminación fue exitosa
  /// - [Left(Failure)]: Si ocurre un error
  /// 
  /// Lanza validaciones si:
  /// - El habitId está vacío
  Future<Either<Failure, void>> execute({
    required String habitId,
  }) async {
    // Validación: ID no vacío
    if (habitId.trim().isEmpty) {
      return Left(
        ValidationFailure('El ID del hábito no puede estar vacío'),
      );
    }
    
    // Ejecutar eliminación
    return await _repository.deleteHabit(habitId);
  }
}

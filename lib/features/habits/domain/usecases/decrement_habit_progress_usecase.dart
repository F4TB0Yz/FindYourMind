import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/core/utils/date_utils.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';

/// Caso de uso para decrementar el progreso diario de un hábito
/// 
/// Encapsula la lógica de negocio para:
/// - Validar que el hábito existe y tiene progreso para hoy
/// - Decrementar el contador del progreso diario
/// - Validar que el contador no sea menor a 0
class DecrementHabitProgressUseCase {
  final HabitRepository _repository;

  DecrementHabitProgressUseCase(this._repository);

  /// Ejecuta el decremento del progreso diario
  /// 
  /// Parámetros:
  /// - [habit]: El hábito completo con su progreso actual
  /// 
  /// Retorna:
  /// - [Right(HabitProgress)]: El progreso actualizado
  /// - [Left(Failure)]: Si ocurre un error
  /// 
  /// Lanza validaciones si:
  /// - El habitId está vacío
  /// - No existe progreso para hoy
  /// - El contador ya está en 0
  Future<Either<Failure, HabitProgress>> execute({
    required HabitEntity habit,
  }) async {
    // Validación: ID del hábito
    if (habit.id.isEmpty) {
      return Left(
        ValidationFailure('El ID del hábito no puede estar vacío'),
      );
    }

    final String todayString = DateInfoUtils.todayString();

    // Buscar progreso de hoy
    final todayProgressIndex = habit.progress.indexWhere(
      (progress) => progress.date == todayString,
    );

    // Validación: No existe progreso para hoy
    if (todayProgressIndex == -1) {
      return Left(
        ValidationFailure('No hay progreso registrado para hoy'),
      );
    }

    final todayProgress = habit.progress[todayProgressIndex];

    // Validación: Contador ya está en 0
    if (todayProgress.dailyCounter <= 0) {
      return Left(
        ValidationFailure('El contador ya está en 0'),
      );
    }

    // Decrementar contador
    final updatedCounter = todayProgress.dailyCounter - 1;

    // Actualizar en el repositorio
    final result = await _repository.updateHabitProgress(
      habit.id,
      todayProgress.id,
      updatedCounter,
    );

    return result.fold(
      (failure) => Left(failure),
      (_) => Right(
        todayProgress.copyWith(dailyCounter: updatedCounter),
      ),
    );
  }
}

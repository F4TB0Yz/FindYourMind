import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';

/// Caso de uso para guardar (crear o actualizar) el progreso de un hábito.
/// 
/// Implementa Idempotencia: el UseCase recibe el objeto final y lo persiste tal cual.
/// No realiza cálculos matemáticos ni genera identidades (UUIDs), delegando esto a la presentación.
class SaveHabitProgressUseCase {
  final HabitRepository _repository;

  SaveHabitProgressUseCase(this._repository);

  /// Ejecuta la persistencia del progreso
  /// 
  /// Parámetros:
  /// - [progress]: El objeto de progreso calculado y listo para guardar.
  /// - [isNew]: Indica si el registro debe ser creado (true) o actualizado (false).
  /// 
  /// Retorna:
  /// - [Right(void)]: Si la operación fue exitosa.
  /// - [Left(Failure)]: Si ocurre un error de validación o persistencia.
  Future<Either<Failure, void>> execute({
    required HabitProgress progress,
    required bool isNew,
  }) async {
    // 1. Validación de Reglas de Negocio
    if (progress.dailyCounter < 0) {
      return Left(ValidationFailure('El contador de progreso no puede ser menor a 0.'));
    }

    if (progress.dailyCounter > progress.dailyGoal) {
      return Left(ValidationFailure(
        'El progreso (${progress.dailyCounter}) no puede exceder la meta diaria (${progress.dailyGoal}).'
      ));
    }

    // 2. Persistencia según el flag de creación
    if (isNew) {
      final result = await _repository.createHabitProgress(habitProgress: progress);
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    } else {
      final result = await _repository.updateHabitCounter(
        habitId: progress.habitId,
        progressId: progress.id,
        newCounter: progress.dailyCounter,
      );
      return result.fold(
        (failure) => Left(failure),
        (_) => const Right(null),
      );
    }
  }
}

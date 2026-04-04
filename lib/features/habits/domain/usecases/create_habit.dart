import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';

/// Caso de uso para crear un hábito y su progreso inicial.
///
/// Implementa el patrón **Client-Side Identity Generation**: asume que el
/// [HabitEntity] recibido ya contiene un `id` válido (UUID v4) y que su
/// lista `progress` contiene exactamente un registro inicial (día 0),
/// ambos generados por la capa de Presentación.
///
/// Responsabilidades:
/// - Validar los datos del hábito antes de persistirlos.
/// - Persistir el hábito en el repositorio.
/// - Extraer el progreso inicial de la entidad y persistirlo.
class CreateHabitUseCase {
  final HabitRepository _repository;

  const CreateHabitUseCase(this._repository);

  /// Valida y persiste el hábito junto a su progreso inicial pre-generado.
  ///
  /// Parámetros:
  /// - [habit]: Entidad con `id` y `progress[0]` ya construidos por el Provider.
  ///
  /// Retorna:
  /// - [Right(String)]: El ID del hábito persistido (igual al recibido).
  /// - [Left(Failure)]: Si la validación o la persistencia fallan.
  Future<Either<Failure, String>> execute({
    required HabitEntity habit,
  }) async {
    // 1. Validaciones de Dominio
    if (habit.title.trim().isEmpty) {
      return Left(ValidationFailure('El título del hábito no puede estar vacío'));
    }

    if (habit.dailyGoal < 1) {
      return Left(ValidationFailure('La meta diaria debe ser al menos 1'));
    }

    if (habit.icon.isEmpty) {
      return Left(ValidationFailure('El icono del hábito no puede estar vacío'));
    }

    // 2. Orquestación: Persistir el Hábito (ya trae su ID del Provider)
    final habitResult = await _repository.createHabit(habit);

    return habitResult.fold(
      (failure) => Left(failure),
      (_) async {
        // 3. Extraer el progreso inicial pre-construido y persistirlo
        if (habit.progress.isEmpty) {
          return Right(habit.id);
        }

        final initialProgress = habit.progress.first;
        final progressResult = await _repository.createHabitProgress(
          habitProgress: initialProgress,
        );

        return progressResult.fold(
          (failure) => Left(failure),
          (_) => Right(habit.id),
        );
      },
    );
  }
}

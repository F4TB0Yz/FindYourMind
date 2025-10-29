import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/core/utils/date_utils.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:uuid/uuid.dart';

/// Caso de uso para incrementar el progreso diario de un hábito
/// 
/// Encapsula la lógica de negocio para:
/// - Validar que el hábito existe y puede ser incrementado
/// - Crear un nuevo registro de progreso si no existe para hoy
/// - Incrementar el contador si ya existe progreso para hoy
/// - Validar que no se exceda la meta diaria
class IncrementHabitProgressUseCase {
  final HabitRepository _repository;

  IncrementHabitProgressUseCase(this._repository);

  /// Ejecuta el incremento del progreso diario
  /// 
  /// Parámetros:
  /// - [habit]: El hábito completo con su progreso actual
  /// 
  /// Retorna:
  /// - [Right(HabitProgress)]: El progreso actualizado o creado
  /// - [Left(Failure)]: Si ocurre un error
  /// 
  /// Lanza validaciones si:
  /// - El habitId está vacío
  /// - Ya se alcanzó la meta diaria
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

    // Caso 1: No existe progreso para hoy - CREAR
    if (todayProgressIndex == -1) {
      final String progressId = const Uuid().v4();
      final newProgress = HabitProgress(
        id: progressId,
        habitId: habit.id,
        date: todayString,
        dailyGoal: habit.dailyGoal,
        dailyCounter: 1,
      );

      // Crear el progreso en el repositorio
      final result = await _repository.createHabitProgress(
        habitProgress: newProgress,
      );

      return result.fold(
        (failure) => Left(failure),
        (_) => Right(newProgress),
      );
    }

    // Caso 2: Ya existe progreso para hoy - INCREMENTAR
    final todayProgress = habit.progress[todayProgressIndex];

    // Validación: Meta diaria alcanzada
    if (todayProgress.dailyCounter >= habit.dailyGoal) {
      return Left(
        ValidationFailure(
          'Ya se alcanzó la meta diaria (${todayProgress.dailyCounter}/${habit.dailyGoal})',
        ),
      );
    }

    // Incrementar contador
    final updatedCounter = todayProgress.dailyCounter + 1;

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

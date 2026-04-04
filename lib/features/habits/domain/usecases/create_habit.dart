import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/core/utils/date_utils.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:uuid/uuid.dart';

/// Caso de uso para crear un hábito y su progreso inicial
/// 
/// Encapsula la lógica de negocio para:
/// - Validar los datos del hábito antes de crearlo
/// - Generar identidades únicas (UUID) en el dominio
/// - Orquestar la creación del hábito y su progreso diario inicial
class CreateHabitUseCase {
  final HabitRepository _repository;
  final Uuid _uuid;

  CreateHabitUseCase(this._repository, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  /// Ejecuta la creación del hábito y su primer registro de progreso
  /// 
  /// Parámetros:
  /// - [habit]: El hábito a crear (sin ID necesario)
  /// 
  /// Retorna:
  /// - [Right(String)]: El ID final del hábito creado
  /// - [Left(Failure)]: Si ocurre un error en cualquiera de los pasos
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

    // 2. Generación de Identidad en el Dominio
    final String habitId = _uuid.v4();
    final String progressId = _uuid.v4();
    final String today = DateInfoUtils.todayString();

    // 3. Preparación de Entidades
    final habitWithId = habit.copyWith(id: habitId, progress: []);
    
    final initialProgress = HabitProgress(
      id: progressId,
      habitId: habitId,
      date: today,
      dailyGoal: habit.dailyGoal,
      dailyCounter: 0,
    );

    // 4. Orquestación: Persistir Hábito
    final habitResult = await _repository.createHabit(habitWithId);
    
    return await habitResult.fold(
      (failure) async => Left(failure),
      (returnedId) async {
        // En un sistema offline-first, el ID retornado debería coincidir con el enviado,
        // pero usamos el retornado por robustez si el repo decide cambiarlo.
        final String finalHabitId = returnedId ?? habitId;

        // 5. Orquestación: Persistir Progreso Inicial (Invisible para la UI al crear)
        final progressResult = await _repository.createHabitProgress(
          habitProgress: initialProgress.copyWith(habitId: finalHabitId),
        );

        return progressResult.fold(
          (failure) => Left(failure),
          (_) => Right(finalHabitId),
        );
      },
    );
  }
}

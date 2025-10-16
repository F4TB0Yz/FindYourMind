import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';

/// Caso de uso para crear un hábito
/// Valida y ejecuta la lógica de negocio para crear un hábito
class CreateHabit {
  final HabitRepository repository;

  CreateHabit(this.repository);

  /// Ejecuta la creación del hábito
  /// 
  /// [habit] Hábito a crear
  Future<Either<Failure, void>> call({required HabitEntity habit}) async {
    // Ejecutar creación
    return await repository.createHabit(habit);
  }
}

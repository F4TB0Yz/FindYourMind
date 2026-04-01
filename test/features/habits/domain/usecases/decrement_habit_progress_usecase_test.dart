import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/core/utils/date_utils.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/entities/type_habit.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:find_your_mind/features/habits/domain/usecases/decrement_habit_progress_usecase.dart';

// Mock del repositorio para simular llamadas a la base de datos
class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late DecrementHabitProgressUseCase usecase;
  late MockHabitRepository mockRepository;

  setUp(() {
    mockRepository = MockHabitRepository();
    usecase = DecrementHabitProgressUseCase(mockRepository);
  });

  final String todayStr = DateInfoUtils.todayString();

  // Hábito con progreso para hoy (meta 8, contador 2)
  final tHabitWithProgress = HabitEntity(
    id: '1',
    userId: 'user123',
    title: 'Drink Water',
    description: 'Stay hydrated',
    icon: 'water_drop',
    type: TypeHabit.health,
    dailyGoal: 8,
    initialDate: '2025-01-01T00:00:00.000',
    progress: [
      HabitProgress(
        id: 'p1',
        habitId: '1',
        date: todayStr,
        dailyGoal: 8,
        dailyCounter: 2,
      )
    ]
  );

  // Hábito con progreso en 0
  final tHabitWithZeroProgress = tHabitWithProgress.copyWith(
    progress: [
      HabitProgress(
        id: 'p1',
        habitId: '1',
        date: todayStr,
        dailyGoal: 8,
        dailyCounter: 0,
      )
    ]
  );

  // Hábito sin progreso para hoy
  final tHabitWithoutProgress = tHabitWithProgress.copyWith(progress: []);

  test('should decrement counter when progress exists and is > 0', () async {
    // --- ARRANGE ---
    when(() => mockRepository.updateHabitCounter(
      habitId: any(named: 'habitId'),
      progressId: any(named: 'progressId'),
      newCounter: any(named: 'newCounter'),
    )).thenAnswer((_) async => const Right(null));

    // --- ACT ---
    final result = await usecase.execute(habit: tHabitWithProgress);

    // --- ASSERT ---
    expect(result.isRight(), true);
    result.fold(
      (_) => fail('Debería ser Right'),
      (progress) {
        expect(progress.dailyCounter, 1); // 2 - 1 = 1
      }
    );
    verify(() => mockRepository.updateHabitCounter(habitId: '1', progressId: 'p1', newCounter: 1)).called(1);
  });

  test('should return ValidationFailure when no progress exists for today', () async {
    // --- ACT ---
    final result = await usecase.execute(habit: tHabitWithoutProgress);

    // --- ASSERT ---
    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Debería ser Left')
    );
    verifyNever(() => mockRepository.updateHabitCounter(habitId: any(named: 'habitId'), progressId: any(named: 'progressId'), newCounter: any(named: 'newCounter')));
  });

  test('should return ValidationFailure when counter is already 0', () async {
    // --- ACT ---
    final result = await usecase.execute(habit: tHabitWithZeroProgress);

    // --- ASSERT ---
    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Debería ser Left')
    );
    verifyNever(() => mockRepository.updateHabitCounter(habitId: any(named: 'habitId'), progressId: any(named: 'progressId'), newCounter: any(named: 'newCounter')));
  });

  test('should return CacheFailure when database fails to update', () async {
    // --- ARRANGE ---
    when(() => mockRepository.updateHabitCounter(
      habitId: any(named: 'habitId'),
      progressId: any(named: 'progressId'),
      newCounter: any(named: 'newCounter'),
    )).thenAnswer((_) async => Left(CacheFailure(message: 'Error de base de datos')));

    // --- ACT ---
    final result = await usecase.execute(habit: tHabitWithProgress);

    // --- ASSERT ---
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<CacheFailure>());
        expect(failure.message, 'Error de base de datos');
      },
      (_) => fail('Debería ser Left')
    );
    verify(() => mockRepository.updateHabitCounter(habitId: '1', progressId: 'p1', newCounter: 1)).called(1);
  });

  test('should return ValidationFailure when habit ID is empty', () async {
    // --- ARRANGE ---
    final tHabitEmptyId = tHabitWithProgress.copyWith(id: '');

    // --- ACT ---
    final result = await usecase.execute(habit: tHabitEmptyId);

    // --- ASSERT ---
    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Debería ser Left')
    );
    verifyNever(() => mockRepository.updateHabitCounter(habitId: any(named: 'habitId'), progressId: any(named: 'progressId'), newCounter: any(named: 'newCounter')));
  });
}

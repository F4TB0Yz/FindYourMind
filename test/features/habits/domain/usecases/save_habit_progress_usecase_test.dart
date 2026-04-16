import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:find_your_mind/features/habits/domain/usecases/save_habit_progress_usecase.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late SaveHabitProgressUseCase usecase;
  late MockHabitRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(HabitProgress(
      id: '', habitId: '', date: '', dailyGoal: 0, dailyCounter: 0
    ));
  });

  setUp(() {
    mockRepository = MockHabitRepository();
    usecase = SaveHabitProgressUseCase(mockRepository);
  });

  final tProgressNew = HabitProgress(
    id: 'p1',
    habitId: 'h1',
    date: '2025-01-01',
    dailyGoal: 8,
    dailyCounter: 1,
  );

  final tProgressUpdate = HabitProgress(
    id: 'p1',
    habitId: 'h1',
    date: '2025-01-01',
    dailyGoal: 8,
    dailyCounter: 2,
  );

  test('should create new progress when isNew is true', () async {
    when(() => mockRepository.createHabitProgress(habitProgress: any(named: 'habitProgress')))
        .thenAnswer((_) async => const Right('p1'));

    final result = await usecase.execute(progress: tProgressNew, isNew: true);

    expect(result.isRight(), true);
    verify(() => mockRepository.createHabitProgress(habitProgress: tProgressNew)).called(1);
    verifyNever(() => mockRepository.updateHabitCounter(
      habitId: any(named: 'habitId'),
      progressId: any(named: 'progressId'),
      newCounter: any(named: 'newCounter'),
    ));
  });

  test('should update existing progress when isNew is false', () async {
    when(() => mockRepository.updateHabitCounter(
      habitId: any(named: 'habitId'),
      progressId: any(named: 'progressId'),
      newCounter: any(named: 'newCounter'),
    )).thenAnswer((_) async => const Right(null));

    final result = await usecase.execute(progress: tProgressUpdate, isNew: false);

    expect(result.isRight(), true);
    verify(() => mockRepository.updateHabitCounter(
      habitId: tProgressUpdate.habitId,
      progressId: tProgressUpdate.id,
      newCounter: tProgressUpdate.dailyCounter,
    )).called(1);
    verifyNever(() => mockRepository.createHabitProgress(habitProgress: any(named: 'habitProgress')));
  });

  test('should return ValidationFailure when daily counter is below 0', () async {
    final invalidProgress = tProgressNew.copyWith(dailyCounter: -1);

    final result = await usecase.execute(progress: invalidProgress, isNew: false);

    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'El contador de progreso no puede ser menor a 0.');
      },
      (_) => fail('Debería ser Left'),
    );
  });

  test('should return ValidationFailure when daily counter exceeds daily goal', () async {
    final invalidProgress = tProgressNew.copyWith(dailyCounter: 9);

    final result = await usecase.execute(progress: invalidProgress, isNew: false);

    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('no puede exceder la meta diaria'));
      },
      (_) => fail('Debería ser Left'),
    );
  });
}

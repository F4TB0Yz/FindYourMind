import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:find_your_mind/features/habits/domain/usecases/save_habit_progress_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late SaveHabitProgressUseCase usecase;
  late MockHabitRepository mockRepository;

  const tLogNew = HabitLog(
    id: 'l1',
    habitId: 'h1',
    date: '2025-01-01',
    value: 1,
  );

  const tLogUpdate = HabitLog(
    id: 'l1',
    habitId: 'h1',
    date: '2025-01-01',
    value: 2,
  );

  setUpAll(() {
    registerFallbackValue(tLogNew);
  });

  setUp(() {
    mockRepository = MockHabitRepository();
    usecase = SaveHabitProgressUseCase(mockRepository);
  });

  test('creates new log when isNew is true', () async {
    when(() => mockRepository.createHabitLog(habitLog: any(named: 'habitLog')))
        .thenAnswer((_) async => const Right('l1'));

    final result = await usecase.execute(progress: tLogNew, isNew: true);

    expect(result.isRight(), true);
    verify(() => mockRepository.createHabitLog(habitLog: tLogNew)).called(1);
  });

  test('updates existing log when isNew is false', () async {
    when(
      () => mockRepository.updateHabitLogValue(
        habitId: any(named: 'habitId'),
        logId: any(named: 'logId'),
        value: any(named: 'value'),
      ),
    ).thenAnswer((_) async => const Right(null));

    final result = await usecase.execute(progress: tLogUpdate, isNew: false);

    expect(result.isRight(), true);
    verify(
      () => mockRepository.updateHabitLogValue(
        habitId: tLogUpdate.habitId,
        logId: tLogUpdate.id,
        value: tLogUpdate.value,
      ),
    ).called(1);
  });

  test('returns ValidationFailure when value is below 0', () async {
    final result = await usecase.execute(
      progress: tLogNew.copyWith(value: -1),
      isNew: false,
    );

    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'El contador de progreso no puede ser menor a 0.');
      },
      (_) => fail('Debería ser Left'),
    );
  });
}

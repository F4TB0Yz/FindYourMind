import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:find_your_mind/features/habits/domain/usecases/create_habit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_utils/test_output_style.dart';

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late CreateHabitUseCase usecase;
  late MockHabitRepository mockRepository;

  const tHabit = HabitEntity(
    id: '1',
    userId: 'user123',
    title: 'Drink Water',
    description: 'Stay hydrated',
    icon: '💧',
    category: HabitCategory.health,
    trackingType: HabitTrackingType.counter,
    targetValue: 8,
    initialDate: '2025-01-01T00:00:00.000',
    logs: [
      HabitLog(id: 'l1', habitId: '1', date: '2025-01-01', value: 0),
    ],
  );

  setUpAll(() {
    registerFallbackValue(tHabit);
    registerFallbackValue(const HabitLog(id: 'x', habitId: 'x', date: 'x', value: 0));
  });

  setUp(() {
    mockRepository = MockHabitRepository();
    usecase = CreateHabitUseCase(mockRepository);
  });

  test(label('llama repositorio createHabit y createHabitLog cuando es válido'), () async {
    when(() => mockRepository.createHabit(any()))
        .thenAnswer((_) async => const Right('1'));
    when(() => mockRepository.createHabitLog(habitLog: any(named: 'habitLog')))
        .thenAnswer((_) async => const Right('l1'));

    final result = await usecase.execute(habit: tHabit);

    expect(result, const Right('1'));
    verify(() => mockRepository.createHabit(tHabit)).called(1);
    verify(
      () => mockRepository.createHabitLog(habitLog: tHabit.logs.first),
    ).called(1);
  });

  test(label('devuelve ValidationFailure cuando título está vacío'), () async {
    final result = await usecase.execute(habit: tHabit.copyWith(title: '  '));

    expect(result.isLeft(), true);
    verifyNever(() => mockRepository.createHabit(any()));
  });

  test(label('devuelve ValidationFailure cuando target < 1'), () async {
    final result = await usecase.execute(habit: tHabit.copyWith(targetValue: 0));

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Debería fallar'),
    );
  });
}

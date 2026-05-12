import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/core/utils/date_utils.dart';
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:find_your_mind/features/habits/domain/usecases/create_habit.dart';
import 'package:find_your_mind/features/habits/domain/usecases/delete_habit_usecase.dart';
import 'package:find_your_mind/features/habits/domain/usecases/save_habit_progress_usecase.dart';
import 'package:find_your_mind/features/habits/domain/usecases/update_habit_usecase.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_utils/test_output_style.dart';

class MockCreateHabitUseCase extends Mock implements CreateHabitUseCase {}

class MockUpdateHabitUseCase extends Mock implements UpdateHabitUseCase {}

class MockDeleteHabitUseCase extends Mock implements DeleteHabitUseCase {}

class MockSaveHabitProgressUseCase extends Mock
    implements SaveHabitProgressUseCase {}

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}

class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late HabitsProvider provider;
  late MockCreateHabitUseCase mockCreateHabitUseCase;
  late MockUpdateHabitUseCase mockUpdateHabitUseCase;
  late MockDeleteHabitUseCase mockDeleteHabitUseCase;
  late MockSaveHabitProgressUseCase mockSaveHabitProgressUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockHabitRepository mockRepository;

  final tUser = UserEntity(
    id: 'user123',
    email: 'test@example.com',
    createdAt: DateTime.now(),
  );

  const tCounterHabit = HabitEntity(
    id: '1',
    userId: 'user123',
    title: 'Drink Water',
    description: 'Stay hydrated',
    icon: '💧',
    category: HabitCategory.health,
    trackingType: HabitTrackingType.counter,
    targetValue: 8,
    initialDate: '2025-01-01T00:00:00.000',
    logs: [],
  );

  setUpAll(() {
    registerFallbackValue(tCounterHabit);
    registerFallbackValue(
      const HabitLog(id: 'l1', habitId: '1', date: 'x', value: 0),
    );
  });

  setUp(() {
    mockCreateHabitUseCase = MockCreateHabitUseCase();
    mockUpdateHabitUseCase = MockUpdateHabitUseCase();
    mockDeleteHabitUseCase = MockDeleteHabitUseCase();
    mockSaveHabitProgressUseCase = MockSaveHabitProgressUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockRepository = MockHabitRepository();

    provider = HabitsProvider(
      createHabitUseCase: mockCreateHabitUseCase,
      updateHabitUseCase: mockUpdateHabitUseCase,
      deleteHabitUseCase: mockDeleteHabitUseCase,
      saveHabitProgressUseCase: mockSaveHabitProgressUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
      repository: mockRepository,
    );
  });

  group(label('loadHabits'), () {
    test(label('carga hábitos desde repositorio'), () async {
      when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => tUser);
      when(
        () => mockRepository.getHabitsByEmailPaginated(
          email: 'user123',
          limit: 10,
          offset: 0,
        ),
      ).thenAnswer((_) async => [tCounterHabit]);

      final future = provider.loadHabits();
      expect(provider.isLoading, true);

      await future;

      expect(provider.isLoading, false);
      expect(provider.habits.length, 1);
      expect(provider.habits.first, tCounterHabit);
    });
  });

  group(label('createHabit'), () {
    test(label('agrega hábito al instante y llama al usecase'), () async {
      when(
        () => mockCreateHabitUseCase.execute(habit: any(named: 'habit')),
      ).thenAnswer((invocation) async {
        final habit = invocation.namedArguments[#habit] as HabitEntity;
        return Right(habit.id);
      });

      final resultId = provider.createHabit(tCounterHabit);

      expect(provider.habits.length, 1);
      expect(resultId, isNotNull);
      expect(provider.habits.first.logs.first.value, 0);

      await Future<void>.delayed(Duration.zero);
      verify(
        () => mockCreateHabitUseCase.execute(habit: any(named: 'habit')),
      ).called(1);
    });
  });

  group(label('logs de contador'), () {
    test(label('incrementa contador optimistamente'), () async {
      final habitWithLog = tCounterHabit.copyWith(
        logs: [
          HabitLog(
            id: 'l1',
            habitId: '1',
            date: DateInfoUtils.todayString(),
            value: 2,
          ),
        ],
      );

      when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => tUser);
      when(
        () => mockRepository.getHabitsByEmailPaginated(
          email: any(named: 'email'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [habitWithLog]);
      when(
        () => mockSaveHabitProgressUseCase.execute(
          progress: any(named: 'progress'),
          isNew: any(named: 'isNew'),
        ),
      ).thenAnswer((_) async => const Right(null));

      await provider.loadHabits();

      final result = await provider.updateHabitCounter('1');

      expect(result, true);
      expect(provider.getTodayCount('1'), 3);
    });

    test(label('decrementa contador optimistamente'), () async {
      final habitWithLog = tCounterHabit.copyWith(
        logs: [
          HabitLog(
            id: 'l1',
            habitId: '1',
            date: DateInfoUtils.todayString(),
            value: 2,
          ),
        ],
      );

      when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => tUser);
      when(
        () => mockRepository.getHabitsByEmailPaginated(
          email: any(named: 'email'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [habitWithLog]);
      when(
        () => mockSaveHabitProgressUseCase.execute(
          progress: any(named: 'progress'),
          isNew: any(named: 'isNew'),
        ),
      ).thenAnswer((_) async => const Right(null));

      await provider.loadHabits();

      final result = await provider.decrementHabitProgress('1');

      expect(result, true);
      expect(provider.getTodayCount('1'), 1);
    });
  });

  group(label('logs de tiempo'), () {
    test(label('setea valor absoluto del log'), () async {
      const timedHabit = HabitEntity(
        id: 't1',
        userId: 'user123',
        title: 'Meditate',
        description: 'Focus',
        icon: '🧘',
        category: HabitCategory.personal,
        trackingType: HabitTrackingType.timed,
        targetValue: 600,
        initialDate: '2025-01-01T00:00:00.000',
        logs: [],
      );

      when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => tUser);
      when(
        () => mockRepository.getHabitsByEmailPaginated(
          email: any(named: 'email'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [timedHabit]);
      when(
        () => mockSaveHabitProgressUseCase.execute(
          progress: any(named: 'progress'),
          isNew: any(named: 'isNew'),
        ),
      ).thenAnswer((_) async => const Right(null));

      await provider.loadHabits();

      final result = await provider.setHabitLogValue('t1', 180);

      expect(result, true);
      expect(provider.getTodayCount('t1'), 180);
    });
  });

  group(label('logs single'), () {
    const singleHabit = HabitEntity(
      id: 's1',
      userId: 'user123',
      title: 'Read',
      description: 'One page',
      icon: '📖',
      category: HabitCategory.personal,
      trackingType: HabitTrackingType.single,
      targetValue: 1,
      initialDate: '2025-01-01T00:00:00.000',
      logs: [],
    );

    test(label('descompleta hábito single seteando value a 0'), () async {
      final existingLog = HabitLog(
        id: 'sl1',
        habitId: 's1',
        date: DateInfoUtils.todayString(),
        value: 1,
      );
      final completedHabit = singleHabit.copyWith(logs: [existingLog]);

      when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => tUser);
      when(
        () => mockRepository.getHabitsByEmailPaginated(
          email: any(named: 'email'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [completedHabit]);
      when(
        () => mockSaveHabitProgressUseCase.execute(
          progress: any(named: 'progress'),
          isNew: any(named: 'isNew'),
        ),
      ).thenAnswer((_) async => const Right(null));

      await provider.loadHabits();

      expect(provider.habits.first.isCompletedToday, true);

      final result = await provider.setHabitLogValue('s1', 0);
      await Future<void>.delayed(Duration.zero);

      expect(result, true);
      expect(provider.getTodayCount('s1'), 0);
      expect(provider.habits.first.isCompletedToday, false);

      final captured = verify(
        () => mockSaveHabitProgressUseCase.execute(
          progress: captureAny(named: 'progress'),
          isNew: false,
        ),
      ).captured;
      final progress = captured.single as HabitLog;

      expect(progress.id, existingLog.id);
      expect(progress.value, 0);
    });

    test(
      label('completa hábito single creando log nuevo si no existe'),
      () async {
        when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => tUser);
        when(
          () => mockRepository.getHabitsByEmailPaginated(
            email: any(named: 'email'),
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          ),
        ).thenAnswer((_) async => [singleHabit]);
        when(
          () => mockSaveHabitProgressUseCase.execute(
            progress: any(named: 'progress'),
            isNew: any(named: 'isNew'),
          ),
        ).thenAnswer((_) async => const Right(null));

        await provider.loadHabits();

        final result = await provider.updateHabitCounter('s1');
        await Future<void>.delayed(Duration.zero);

        expect(result, true);
        expect(provider.getTodayCount('s1'), 1);
        expect(provider.habits.first.isCompletedToday, true);

        final captured = verify(
          () => mockSaveHabitProgressUseCase.execute(
            progress: captureAny(named: 'progress'),
            isNew: true,
          ),
        ).captured;
        final progress = captured.single as HabitLog;

        expect(progress.habitId, 's1');
        expect(progress.value, 1);
      },
    );

    test(label('revierte descompletar optimista si falla'), () async {
      final existingLog = HabitLog(
        id: 'sl1',
        habitId: 's1',
        date: DateInfoUtils.todayString(),
        value: 1,
      );
      final completedHabit = singleHabit.copyWith(logs: [existingLog]);

      when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => tUser);
      when(
        () => mockRepository.getHabitsByEmailPaginated(
          email: any(named: 'email'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [completedHabit]);
      when(
        () => mockSaveHabitProgressUseCase.execute(
          progress: any(named: 'progress'),
          isNew: any(named: 'isNew'),
        ),
      ).thenAnswer(
        (_) async => Left(ServerFailure(message: 'No se pudo guardar')),
      );

      await provider.loadHabits();

      final result = await provider.setHabitLogValue('s1', 0);

      expect(result, true);
      expect(provider.getTodayCount('s1'), 0);

      await Future<void>.delayed(Duration.zero);

      expect(provider.getTodayCount('s1'), 1);
      expect(provider.habits.first.isCompletedToday, true);
    });
  });
}

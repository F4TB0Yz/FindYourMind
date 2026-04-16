import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/domain/usecases/create_habit.dart';
import 'package:find_your_mind/features/habits/domain/usecases/update_habit_usecase.dart';
import 'package:find_your_mind/features/habits/domain/usecases/delete_habit_usecase.dart';
import 'package:find_your_mind/features/habits/domain/usecases/save_habit_progress_usecase.dart';
import 'package:find_your_mind/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/type_habit.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/core/utils/date_utils.dart';
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';

// Mocks de los casos de uso y repositorio para simular dependencias
class MockCreateHabitUseCase extends Mock implements CreateHabitUseCase {}
class MockUpdateHabitUseCase extends Mock implements UpdateHabitUseCase {}
class MockDeleteHabitUseCase extends Mock implements DeleteHabitUseCase {}
class MockSaveHabitProgressUseCase extends Mock implements SaveHabitProgressUseCase {}
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

  setUpAll(() {
    // Registrar fallback para HabitEntity para que mocktail sepa manejarlo en any()
    registerFallbackValue(HabitEntity(
      id: '', userId: '', title: '', description: '', icon: '',
      type: TypeHabit.none, dailyGoal: 0, initialDate: '', progress: []
    ));
  });

  setUp(() {
    // Inicializar mocks y el provider antes de cada prueba
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

  // Usuario de prueba base
  final tUser = UserEntity(
    id: 'user123',
    email: 'test@example.com',
    createdAt: DateTime.now(),
  );

  // Hábito de prueba base
  final tHabit = HabitEntity(
    id: '1',
    userId: 'user123',
    title: 'Drink Water',
    description: 'Stay hydrated',
    icon: 'water_drop',
    type: TypeHabit.health,
    dailyGoal: 8,
    initialDate: '2025-01-01T00:00:00.000',
    progress: []
  );

  group('loadHabits', () {
    test('should set isLoading to true and load habits from repository', () async {
      // --- ARRANGE (Preparación) ---
      // Simular que se obtiene el usuario actual
      when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => tUser);
      // Simular carga de hábitos desde el repositorio
      when(() => mockRepository.getHabitsByEmailPaginated(
            email: 'user123',
            limit: 10,
            offset: 0,
          )).thenAnswer((_) async => [tHabit]);

      // --- ACT (Ejecución) y ASSERT Optimista de carga ---
      final future = provider.loadHabits();
      // El estado debe cambiar a cargando INMEDIATAMENTE al iniciar la llamada
      expect(provider.isLoading, true); 

      await future;

      // --- ASSERT (Verificación final) ---
      expect(provider.isLoading, false); // Ya no debe estar cargando
      expect(provider.habits.length, 1);
      expect(provider.habits.first, tHabit);
    });

    test('should set error when repository fails', () async {
      // --- ARRANGE (Preparación) ---
      when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => tUser);
      when(() => mockRepository.getHabitsByEmailPaginated(
            email: 'user123',
            limit: any(named: 'limit'),
            offset: any(named: 'offset'),
          )).thenThrow(Exception('Database error'));

      // --- ACT (Ejecución) ---
      await provider.loadHabits();

      // --- ASSERT (Verificación) ---
      expect(provider.isLoading, false);
      expect(provider.hasError, true);
      expect(provider.lastError, contains('Database error'));
    });
  });

  group('createHabit', () {
    test('should add habit to list immediately (optimistic) and call usecase', () async {
      // --- ARRANGE (Preparación) ---
      // Simular que el caso de uso responde exitosamente retornando el ID del hábito recibido
      when(() => mockCreateHabitUseCase.execute(habit: any(named: 'habit')))
          .thenAnswer((invocation) async => Right((invocation.namedArguments[#habit] as HabitEntity).id));

      // --- ACT (Ejecución) ---
      final resultId = await provider.createHabit(tHabit);

      // --- ASSERT (Verificación Optimista) ---
      // Verificamos que se agregó a la lista INMEDIATAMENTE (antes de que la operación de base de datos se complete)
      expect(provider.habits.length, 1);
      expect(resultId, isNotNull);
      
      // Esperar a que la operación asíncrona (then) del provider se complete en segundo plano (simular el delay de base de datos)
      await Future.delayed(Duration.zero);
      
      // Verificar que se llamó al caso de uso
      verify(() => mockCreateHabitUseCase.execute(habit: any(named: 'habit'))).called(1);
    });
  });

  group('updateHabitCounter', () {
    test('should increment counter optimistaclly and call usecase', () async {
      // --- ARRANGE ---
      final habitWithProgress = tHabit.copyWith(
        progress: [
          HabitProgress(
            id: 'p1',
            habitId: '1',
            date: DateInfoUtils.todayString(),
            dailyGoal: 8,
            dailyCounter: 2,
          )
        ]
      );
      
      // Reinicializar provider con el hábito
      when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => tUser);
      when(() => mockRepository.getHabitsByEmailPaginated(
        email: any(named: 'email'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => [habitWithProgress]);
      
      await provider.loadHabits();

      // Stub para el nuevo caso de uso
      when(() => mockSaveHabitProgressUseCase.execute(
        progress: any(named: 'progress'),
        isNew: any(named: 'isNew'),
      )).thenAnswer((_) async => const Right(null));

      // --- ACT ---
      final result = await provider.updateHabitCounter('1');

      // --- ASSERT ---
      expect(result, true);
      expect(provider.getTodayCount('1'), 3); // Optimista
      
      await Future.delayed(Duration.zero);
      verify(() => mockSaveHabitProgressUseCase.execute(
        progress: any(named: 'progress'),
        isNew: false, // Ya existía progreso
      )).called(1);
    });
  });

  group('decrementHabitProgress', () {
    test('should decrement counter optimistaclly and call usecase', () async {
      // --- ARRANGE ---
      final habitWithProgress = tHabit.copyWith(
        progress: [
          HabitProgress(
            id: 'p1',
            habitId: '1',
            date: DateInfoUtils.todayString(),
            dailyGoal: 8,
            dailyCounter: 2,
          )
        ]
      );
      
      when(() => mockGetCurrentUserUseCase()).thenAnswer((_) async => tUser);
      when(() => mockRepository.getHabitsByEmailPaginated(
        email: any(named: 'email'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => [habitWithProgress]);
      
      await provider.loadHabits();

      // Stub para el nuevo caso de uso
      when(() => mockSaveHabitProgressUseCase.execute(
        progress: any(named: 'progress'),
        isNew: any(named: 'isNew'),
      )).thenAnswer((_) async => const Right(null));

      // --- ACT ---
      final result = await provider.decrementHabitProgress('1');

      // --- ASSERT ---
      expect(result, true);
      expect(provider.getTodayCount('1'), 1); // Optimista
      
      await Future.delayed(Duration.zero);
      verify(() => mockSaveHabitProgressUseCase.execute(
        progress: any(named: 'progress'),
        isNew: false, // Ya existía progreso
      )).called(1);
    });
  });
}

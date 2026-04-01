import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/core/utils/date_utils.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/entities/type_habit.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:find_your_mind/features/habits/domain/usecases/update_habit_counter_usecase.dart';

// Mock del repositorio para simular llamadas a la base de datos sin ejecutar lógica real
class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late UpdateHabitCounterUseCase usecase;
  late MockHabitRepository mockRepository;

  setUpAll(() {
    // Registrar fallback para que mocktail sepa manejar el tipo HabitProgress en any()
    registerFallbackValue(HabitProgress(
      id: '', habitId: '', date: '', dailyGoal: 0, dailyCounter: 0
    ));
  });

  setUp(() {
    // Inicializar el caso de uso y su dependencia mockeada antes de cada prueba
    mockRepository = MockHabitRepository();
    usecase = UpdateHabitCounterUseCase(mockRepository);
  });

  final String todayStr = DateInfoUtils.todayString();

  // Hábito sin progreso para hoy (lista vacía)
  final tHabitWithoutProgress = HabitEntity(
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

  test('should create new progress when no progress exists for today', () async {
    // --- ARRANGE (Preparación) ---
    // Simular que el repositorio responde con éxito al CREAR un registro de progreso nuevo
    when(() => mockRepository.createHabitProgress(habitProgress: any(named: 'habitProgress')))
        .thenAnswer((_) async => const Right('generated-p1'));

    // --- ACT (Ejecución) ---
    final result = await usecase.execute(habit: tHabitWithoutProgress);

    // --- ASSERT (Verificación) ---
    expect(result.isRight(), true);
    result.fold(
      (_) => fail('Debería ser Right'),
      (progress) {
        expect(progress.dailyCounter, 1); // 0 + 1 = 1
        expect(progress.date, todayStr);
      }
    );
    // Verificar que se llamó a createHabitProgress en el repositorio
    verify(() => mockRepository.createHabitProgress(habitProgress: any(named: 'habitProgress'))).called(1);
    // Verificar que NUNCA se intentó actualizar un progreso existente
    verifyNever(() => mockRepository.updateHabitCounter(
      habitId: any(named: 'habitId'),
      progressId: any(named: 'progressId'),
      newCounter: any(named: 'newCounter'),
    ));
  });

  test('should increment counter when progress exists for today', () async {
    // --- ARRANGE (Preparación) ---
    // Simular que el repositorio responde con éxito al ACTUALIZAR un progreso existente
    when(() => mockRepository.updateHabitCounter(
      habitId: any(named: 'habitId'),
      progressId: any(named: 'progressId'),
      newCounter: any(named: 'newCounter'),
    )).thenAnswer((_) async => const Right(null));

    // --- ACT (Ejecución) ---
    final result = await usecase.execute(habit: tHabitWithProgress);

    // --- ASSERT (Verificación) ---
    expect(result.isRight(), true);
    result.fold(
      (_) => fail('Debería ser Right'),
      (progress) {
        expect(progress.dailyCounter, 3); // 2 + 1 = 3
      }
    );
    // Verificar que se llamó a updateHabitCounter en el repositorio con los parámetros correctos
    verify(() => mockRepository.updateHabitCounter(
      habitId: '1',
      progressId: 'p1',
      newCounter: 3,
    )).called(1);
    // Verificar que NUNCA se intentó crear uno nuevo
    verifyNever(() => mockRepository.createHabitProgress(habitProgress: any(named: 'habitProgress')));
  });

  test('should return ValidationFailure when daily goal is reached', () async {
    // --- ARRANGE (Preparación) ---
    // Crear un hábito con meta ya alcanzada (8/8)
    final fullProgressHabit = tHabitWithProgress.copyWith(
      progress: [
        HabitProgress(
          id: 'p1',
          habitId: '1',
          date: todayStr,
          dailyGoal: 8,
          dailyCounter: 8, // Meta alcanzada
        )
      ]
    );

    // --- ACT (Ejecución) ---
    final result = await usecase.execute(habit: fullProgressHabit);

    // --- ASSERT (Verificación) ---
    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Debería ser Left')
    );
    // Verificar que NUNCA se procedió a actualizar en el repositorio
    verifyNever(() => mockRepository.updateHabitCounter(
      habitId: any(named: 'habitId'),
      progressId: any(named: 'progressId'),
      newCounter: any(named: 'newCounter'),
    ));
  });

  test('should return CacheFailure when database fails to update progress', () async {
    // --- ARRANGE (Preparación) ---
    // Simular que el repositorio devuelve un CacheFailure (Error de BD local)
    when(() => mockRepository.updateHabitCounter(
      habitId: any(named: 'habitId'),
      progressId: any(named: 'progressId'),
      newCounter: any(named: 'newCounter'),
    )).thenAnswer((_) async => Left(CacheFailure(message: 'Error de base de datos')));

    // --- ACT (Ejecución) ---
    final result = await usecase.execute(habit: tHabitWithProgress);

    // --- ASSERT (Verificación) ---
    expect(result.isLeft(), true);
    result.fold(
      (failure) {
        expect(failure, isA<CacheFailure>());
        expect(failure.message, 'Error de base de datos');
      },
      (_) => fail('Debería ser Left'),
    );
    // Verificar que se llamó al repositorio pero el use case retornó el fallo adecuadamente
    verify(() => mockRepository.updateHabitCounter(
      habitId: '1',
      progressId: 'p1',
      newCounter: 3,
    )).called(1);
  });
}

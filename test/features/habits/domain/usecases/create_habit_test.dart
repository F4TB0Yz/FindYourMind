import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/type_habit.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:find_your_mind/features/habits/domain/usecases/create_habit.dart';

// Mock del repositorio para simular llamadas a la base de datos sin ejecutar lógica real
class MockHabitRepository extends Mock implements HabitRepository {}

void main() {
  late CreateHabitUseCase usecase;
  late MockHabitRepository mockRepository;

  setUpAll(() {
    // Registrar fallback para que mocktail sepa manejar el tipo HabitEntity en any()
    registerFallbackValue(const HabitEntity(
      id: '', userId: '', title: '', description: '', icon: '',
      type: TypeHabit.none, dailyGoal: 0, initialDate: '', progress: []
    ));
  });

  setUp(() {
    // Inicializar el caso de uso y su dependencia mockeada antes de cada prueba
    mockRepository = MockHabitRepository();
    usecase = CreateHabitUseCase(mockRepository);
  });

  // Hábito de prueba base válido
  const tHabit = HabitEntity(
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

  test('should call createHabit on repository when validation passes', () async {
    // --- ARRANGE (Preparación) ---
    // Simular que el repositorio responde con éxito (Right con el ID)
    when(() => mockRepository.createHabit(any()))
        .thenAnswer((_) async => const Right('1'));

    // --- ACT (Ejecución) ---
    // Ejecutar la lógica de negocio del caso de uso
    final result = await usecase.execute(habit: tHabit);

    // --- ASSERT (Verificación) ---
    // Verificar que el resultado sea Right('1')
    expect(result, const Right('1'));
    // Verificar que se haya llamado al repositorio una sola vez con el objeto correcto
    verify(() => mockRepository.createHabit(tHabit)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ValidationFailure when title is empty', () async {
    // --- ARRANGE (Preparación) ---
    // Crear una versión defectuosa del hábito (título vacío)
    final emptyTitleHabit = tHabit.copyWith(title: '  ');

    // --- ACT (Ejecución) ---
    final result = await usecase.execute(habit: emptyTitleHabit);

    // --- ASSERT (Verificación) ---
    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure, isA<ValidationFailure>()),
      (_) => fail('Debería retornar una Falla de Validación'),
    );
    // Verificar que NUNCA se intentó guardar en la base de datos
    verifyNever(() => mockRepository.createHabit(any()));
  });

  test('should return ValidationFailure when daily goal is less than 1', () async {
    // --- ARRANGE (Preparación) ---
    final invalidGoalHabit = tHabit.copyWith(dailyGoal: 0);

    // --- ACT (Ejecución) ---
    final result = await usecase.execute(habit: invalidGoalHabit);

    // --- ASSERT (Verificación) ---
    expect(result.isLeft(), true);
    verifyNever(() => mockRepository.createHabit(any()));
  });

  test('should return ValidationFailure when icon is empty', () async {
    // --- ARRANGE (Preparación) ---
    final emptyIconHabit = tHabit.copyWith(icon: '');

    // --- ACT (Ejecución) ---
    final result = await usecase.execute(habit: emptyIconHabit);

    // --- ASSERT (Verificación) ---
    expect(result.isLeft(), true);
    verifyNever(() => mockRepository.createHabit(any()));
  });
}

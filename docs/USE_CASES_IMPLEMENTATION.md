# Implementación de Casos de Uso para Hábitos

## 📋 Resumen

Se implementaron y refactorizaron todos los casos de uso del módulo de hábitos siguiendo los principios de **Clean Architecture** y las mejores prácticas de Flutter.

## ✅ Casos de Uso Implementados

### 1. **IncrementHabitProgressUseCase** (Nuevo ✨)
**Ubicación:** `lib/features/habits/domain/usecases/increment_habit_progress_usecase.dart`

**Responsabilidades:**
- Validar que el hábito existe y puede ser incrementado
- Crear un nuevo registro de progreso si no existe para hoy
- Incrementar el contador si ya existe progreso para hoy
- Validar que no se exceda la meta diaria

**Validaciones:**
- ✅ ID del hábito no vacío
- ✅ Meta diaria no alcanzada

---

### 2. **DecrementHabitProgressUseCase** (Nuevo ✨)
**Ubicación:** `lib/features/habits/domain/usecases/decrement_habit_progress_usecase.dart`

**Responsabilidades:**
- Validar que el hábito existe y tiene progreso para hoy
- Decrementar el contador del progreso diario
- Validar que el contador no sea menor a 0

**Validaciones:**
- ✅ ID del hábito no vacío
- ✅ Existe progreso para hoy
- ✅ Contador mayor a 0

---

### 3. **CreateHabitUseCase** (Refactorizado 🔄)
**Ubicación:** `lib/features/habits/domain/usecases/create_habit.dart`

**Cambios:**
- ❌ Antes: `call()` sin validaciones
- ✅ Ahora: `execute()` con validaciones completas

**Validaciones:**
- ✅ Título no vacío
- ✅ Meta diaria ≥ 1
- ✅ Icono no vacío

**Retorno:** `Either<Failure, String?>` (ID del hábito creado)

---

### 4. **UpdateHabitUseCase** (Refactorizado 🔄)
**Ubicación:** `lib/features/habits/domain/usecases/update_habit_usecase.dart`

**Cambios:**
- ❌ Antes: Lanzaba excepciones
- ✅ Ahora: Retorna `Either<Failure, void>`

**Validaciones:**
- ✅ ID no vacío
- ✅ Título no vacío
- ✅ Meta diaria ≥ 1
- ✅ Icono no vacío

---

### 5. **DeleteHabitUseCase** (Refactorizado 🔄)
**Ubicación:** `lib/features/habits/domain/usecases/delete_habit_usecase.dart`

**Cambios:**
- ❌ Antes: Lanzaba `ArgumentError`
- ✅ Ahora: Retorna `Either<Failure, void>`

**Validaciones:**
- ✅ ID no vacío

---

## 🏗️ Arquitectura

### Patrón Aplicado: **Clean Architecture**

```
┌─────────────────────────────────────────────────────────────┐
│                      Presentation Layer                      │
│  ┌───────────────────────────────────────────────────────┐  │
│  │             HabitsProvider (UI Logic)                 │  │
│  │  - Actualización optimista                            │  │
│  │  - Manejo de estado                                   │  │
│  │  - Notificaciones                                     │  │
│  └───────────────┬───────────────────────────────────────┘  │
└──────────────────┼──────────────────────────────────────────┘
                   │ Usa
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│  ┌───────────────────────────────────────────────────────┐  │
│  │                   Use Cases                           │  │
│  │  - IncrementHabitProgressUseCase                      │  │
│  │  - DecrementHabitProgressUseCase                      │  │
│  │  - CreateHabitUseCase                                 │  │
│  │  - UpdateHabitUseCase                                 │  │
│  │  - DeleteHabitUseCase                                 │  │
│  │                                                        │  │
│  │  Validaciones + Lógica de Negocio                     │  │
│  └───────────────┬───────────────────────────────────────┘  │
└──────────────────┼──────────────────────────────────────────┘
                   │ Usa
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              HabitRepository                          │  │
│  │  - Persistencia (SQLite + Supabase)                   │  │
│  │  - Sincronización                                     │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔧 Inyección de Dependencias

### DependencyInjection (Actualizado)
**Ubicación:** `lib/core/config/dependency_injection.dart`

```dart
// Nuevos casos de uso registrados
_createHabitUseCase = CreateHabitUseCase(_habitRepository);
_updateHabitUseCase = UpdateHabitUseCase(_habitRepository);
_deleteHabitUseCase = DeleteHabitUseCase(_habitRepository);
_incrementHabitProgressUseCase = IncrementHabitProgressUseCase(_habitRepository);
_decrementHabitProgressUseCase = DecrementHabitProgressUseCase(_habitRepository);
```

### HabitsProvider (Constructor con DI)
```dart
HabitsProvider({
  required CreateHabitUseCase createHabitUseCase,
  required UpdateHabitUseCase updateHabitUseCase,
  required DeleteHabitUseCase deleteHabitUseCase,
  required IncrementHabitProgressUseCase incrementHabitProgressUseCase,
  required DecrementHabitProgressUseCase decrementHabitProgressUseCase,
  required HabitRepositoryImpl repository,
})
```

### Main.dart (Configuración)
```dart
final di = DependencyInjection();

ChangeNotifierProvider(
  create: (_) => HabitsProvider(
    createHabitUseCase: di.createHabitUseCase,
    updateHabitUseCase: di.updateHabitUseCase,
    deleteHabitUseCase: di.deleteHabitUseCase,
    incrementHabitProgressUseCase: di.incrementHabitProgressUseCase,
    decrementHabitProgressUseCase: di.decrementHabitProgressUseCase,
    repository: di.habitRepository as HabitRepositoryImpl,
  ),
),
```

---

## 📝 Cambios en HabitsProvider

### Antes (Lógica en el Provider)
```dart
Future<bool> incrementHabitProgress(String habitId) async {
  // 100+ líneas de lógica de negocio mezclada con UI
  final habit = _habits[habitIndex];
  final todayString = DateInfoUtils.todayString();
  
  if (todayIndex == -1) {
    // Crear progreso...
  } else {
    // Actualizar progreso...
    if (todayProgress.dailyCounter >= habit.dailyGoal) {
      // Validación...
    }
  }
  // ...
}
```

### Después (Delegación a Caso de Uso)
```dart
Future<bool> _executeIncrementProgress(String habitId) async {
  // Solo 30 líneas - Separación clara de responsabilidades
  final habit = _habits[habitIndex];

  // Ejecutar caso de uso (validaciones + lógica)
  final result = await _incrementHabitProgressUseCase.execute(habit: habit);

  return result.fold(
    (failure) => false, // Manejo de errores
    (updatedProgress) {
      updateHabitProgressOptimistic(updatedProgress); // UI
      _notifyPendingChanges(); // Sincronización
      return true;
    },
  );
}
```

---

## 🎯 Beneficios

### 1. **Separación de Responsabilidades**
- ✅ **Provider:** Solo maneja estado y UI optimista
- ✅ **Use Cases:** Lógica de negocio y validaciones
- ✅ **Repository:** Persistencia y sincronización

### 2. **Código más Legible**
- ✅ Métodos más cortos (~30 líneas vs ~100 líneas)
- ✅ Nombres descriptivos
- ✅ Comentarios claros

### 3. **Facilita Testing**
- ✅ Casos de uso independientes y testeables
- ✅ Mock de dependencias más sencillo
- ✅ Tests unitarios por capa

### 4. **Mantenibilidad**
- ✅ Cambios en lógica de negocio solo afectan a use cases
- ✅ Fácil agregar nuevas validaciones
- ✅ Reutilización de casos de uso

### 5. **Consistencia**
- ✅ Todos los casos de uso usan `execute()`
- ✅ Todos retornan `Either<Failure, T>`
- ✅ Validaciones completas en todos

---

## 🚀 Manejo de Errores

### ValidationFailure (Nuevo)
**Ubicación:** `lib/core/error/failures.dart`

```dart
class ValidationFailure extends Failure {
  final String message;
  ValidationFailure(this.message);
  
  @override
  List<Object?> get props => [message];
}
```

### Ejemplos de Uso
```dart
// Caso de uso
if (habit.title.trim().isEmpty) {
  return Left(ValidationFailure('El título no puede estar vacío'));
}

// Provider
result.fold(
  (failure) => print('Error: ${failure.message}'),
  (success) => print('Éxito'),
);
```

---

## 📊 Comparación de Complejidad

| Método | Antes (líneas) | Después (líneas) | Reducción |
|--------|---------------|------------------|-----------|
| `incrementHabitProgress` | ~100 | ~30 | 70% ⬇️ |
| `decrementHabitProgress` | ~60 | ~30 | 50% ⬇️ |
| `createHabit` | ~50 | ~35 | 30% ⬇️ |
| `updateHabit` | ~45 | ~35 | 22% ⬇️ |
| `deleteHabit` | ~30 | ~30 | 0% |

**Total:** ~285 líneas → ~160 líneas = **43% menos código** en el provider

---

## ✅ Checklist de Implementación

- [x] Crear `IncrementHabitProgressUseCase`
- [x] Crear `DecrementHabitProgressUseCase`
- [x] Refactorizar `CreateHabitUseCase`
- [x] Refactorizar `UpdateHabitUseCase`
- [x] Refactorizar `DeleteHabitUseCase`
- [x] Agregar `ValidationFailure`
- [x] Registrar casos de uso en DI
- [x] Actualizar `HabitsProvider` constructor
- [x] Actualizar `main.dart`
- [x] Verificar que no hay errores de compilación

---

## 🔍 Testing Recomendado

### Unit Tests para Use Cases
```dart
test('IncrementHabitProgressUseCase - debería incrementar cuando no existe progreso', () async {
  // Arrange
  final habit = HabitEntity(...);
  final useCase = IncrementHabitProgressUseCase(mockRepository);
  
  // Act
  final result = await useCase.execute(habit: habit);
  
  // Assert
  expect(result.isRight(), true);
  result.fold(
    (l) => fail('No debería fallar'),
    (progress) => expect(progress.dailyCounter, 1),
  );
});
```

---

## 📚 Referencias

- **Clean Architecture:** Robert C. Martin
- **Either Pattern:** Functional Programming (dartz)
- **Dependency Injection:** Martin Fowler
- **SOLID Principles:** Single Responsibility

---

## 🎉 Resultado Final

**Código más limpio, mantenible y testeable** siguiendo las mejores prácticas de arquitectura de software.

Fecha de implementación: 28 de octubre de 2025

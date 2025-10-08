# Arquitectura Limpia - Actualización de Hábitos

## 📁 Estructura de Capas

```
lib/features/habits/
├── domain/                          # Capa de Dominio (Lógica de Negocio)
│   ├── entities/
│   │   └── habit_entity.dart        # Entidad del hábito
│   ├── repositories/
│   │   └── habit_repository.dart    # Contrato del repositorio (abstracto)
│   └── usecases/
│       └── update_habit_usecase.dart # Caso de uso para actualizar hábito
│
├── data/                            # Capa de Datos (Implementación)
│   └── repositories/
│       └── habit_repository_impl.dart # Implementación concreta del repositorio
│
└── presentation/                     # Capa de Presentación (UI)
    ├── providers/
    │   └── habits_provider.dart      # Estado y coordinación
    └── screens/
        └── habit_detail_screen.dart  # Pantalla de detalle/edición
```

## 🔄 Flujo de Actualización

```
┌─────────────────────┐
│ HabitDetailScreen   │ (UI)
│ - Formulario        │
│ - Botones           │
└──────────┬──────────┘
           │ 1. Usuario edita y guarda
           ▼
┌─────────────────────┐
│ HabitsProvider      │ (Coordinador)
│ - updateHabit()     │
└──────────┬──────────┘
           │ 2. Llama al caso de uso
           ▼
┌─────────────────────┐
│ UpdateHabitUseCase  │ (Lógica de Negocio)
│ - Validaciones      │
│ - Reglas            │
└──────────┬──────────┘
           │ 3. Ejecuta validaciones
           ▼
┌─────────────────────┐
│ HabitRepository     │ (Contrato)
│ (Interface)         │
└──────────┬──────────┘
           │ 4. Implementación
           ▼
┌─────────────────────┐
│ HabitRepositoryImpl │ (Implementación)
│                     │
└──────────┬──────────┘
           │ 5. Llama al servicio
           ▼
┌─────────────────────┐
│ SupabaseHabitsServ. │ (Capa de Datos)
│ - updateHabit()     │
│ - Query Supabase    │
└──────────┬──────────┘
           │ 6. Actualiza en BD
           ▼
     ┌──────────┐
     │ Supabase │
     │ Database │
     └──────────┘
```

## 🎯 Responsabilidades

### **Domain Layer** (Independiente de frameworks)
- **HabitRepository (Interface)**: Define QUÉ operaciones se pueden hacer
- **UpdateHabitUseCase**: Encapsula la lógica de negocio y validaciones
  - ✅ Valida que el título no esté vacío
  - ✅ Valida que dailyGoal sea >= 1
  - ✅ Coordina la actualización

### **Data Layer** (Implementación)
- **HabitRepositoryImpl**: Implementa CÓMO se hacen las operaciones
  - Delega a `SupabaseHabitsService`
  - Puede cambiar la fuente de datos sin afectar el dominio

- **SupabaseHabitsService**: Maneja la conexión con Supabase
  - Query: `UPDATE habits SET title, description, icon, daily_goal WHERE id`

### **Presentation Layer** (UI y Estado)
- **HabitsProvider**: Gestiona el estado y coordina las acciones
  - Instancia el caso de uso con sus dependencias
  - Actualiza el estado local después de guardar
  - Notifica a los listeners

- **HabitDetailScreen**: Interfaz de usuario
  - Formulario de edición
  - Llama a `habitsProvider.updateHabit()`
  - Maneja mensajes de éxito/error

## 💡 Beneficios de esta Arquitectura

1. **Separación de Responsabilidades**: Cada capa tiene un propósito claro
2. **Testeable**: Cada componente se puede testear independientemente
3. **Mantenible**: Cambios en una capa no afectan otras
4. **Escalable**: Fácil agregar nuevos casos de uso
5. **Independiente de Frameworks**: La lógica de negocio no depende de Flutter o Supabase

## 🔧 Métodos Implementados

### En `SupabaseHabitsService`:
```dart
Future<void> updateHabit(HabitEntity habit)
```
- Actualiza: título, descripción, icono, meta diaria

### En `HabitRepository` (Interface):
```dart
Future<void> updateHabit(HabitEntity habit);
```

### En `UpdateHabitUseCase`:
```dart
Future<void> execute(HabitEntity habit)
```
- Incluye validaciones de negocio

### En `HabitsProvider`:
```dart
Future<void> updateHabit(HabitEntity updatedHabit)
```
- Usa el caso de uso
- Actualiza estado local
- Notifica listeners

## 📝 Ejemplo de Uso

```dart
// En HabitDetailScreen
final updatedHabit = widget.habit.copyWith(
  title: _titleController.text.trim(),
  description: _descriptionController.text.trim(),
  icon: _selectedIcon,
  dailyGoal: _dailyGoal,
);

// Esto ejecuta toda la cadena de arquitectura limpia
await habitsProvider.updateHabit(updatedHabit);
```

## ✅ Validaciones Incluidas

- ❌ Título vacío → Exception
- ❌ Meta diaria < 1 → Exception
- ✅ Datos válidos → Actualización exitosa

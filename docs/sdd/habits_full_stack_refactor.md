# SDD: Habits Module — Full Stack Refactor

**Fecha:** 2026-05-05
**Estado:** Propuesta
**Alcance:** Domain + Presentation (Habits)

---

## 1. Análisis Estado Actual

### Problemas Identificados

| # | Problema | Archivo | Línea | Impacto |
|---|----------|---------|-------|---------|
| P1 | `_activeFilter` vive en `_HabitsSectionState` (presentation state local) | `habits_redesign_screen.dart:53` | Lógica de negocio en widget |
| P2 | `_colorFor` usa hash de `habitId` + colores hardcodeados | `habits_redesign_screen.dart:57-90` | Debería ser propiedad de `HabitEntity` |
| P3 | `_buildHabitCard` es method-widget (80+ líneas) | `habits_redesign_screen.dart:242-338` | Viola regla "zero method-widgets" |
| P4 | `context.watch<HabitsProvider>` rebuilda todo el árbol | `habits_redesign_screen.dart:96` | Performance: rebuild innecesario |
| P5 | Botón crear hábito inline con `showModalBottomSheet` hardcoded | `habits_redesign_screen.dart:149-206` | No reutilizable, no sigue design tokens |
| P6 | Filtro chips inline con `setState` | `habits_redesign_screen.dart:125-147` | Estado debería estar en provider |
| P7 | Colores `_cardColors` hardcodeados fuera de `AppColors` | `habits_redesign_screen.dart:57-63` | Viola design system |
| P8 | Text styles inline sin usar `AppTextStyles` | `habits_redesign_screen.dart:117-121, 396-400` | Viola design tokens |
| P9 | `Offstage` pattern mezclado con lógica de renderizado | `habits_redesign_screen.dart:223-237` | Difícil de testear, acoplado |

---

## 2. Objetivos del Refactor

1. **Filter state → HabitsProvider**: `_activeFilter` enum + getter de hábitos filtrados
2. **Color assignment → HabitEntity**: `cardColor` getter determinístico en entity
3. **Zero method-widgets**: Cada componente extraído a clase StatelessWidget/StatefulWidget
4. **Clean Architecture estricta**: Domain sin imports de presentation/data
5. **Design tokens**: Todo color/texto via `AppColors` + `AppTextStyles`
6. **Performance**: `Selector` en lugar de `watch`, `const` donde sea posible

---

## 3. Cambios por Capa

### 3.1 Domain Layer — `habit_entity.dart`

#### Nuevo getter: `cardColor`

```dart
// Constante a nivel de archivo (fuera de la clase)
const _kHabitCardColors = [
  Color(0xFFDFFECF), // verde menta
  Color(0xFFD6F5FF), // cyan claro
  Color(0xFFE8D8FF), // lavanda
  Color(0xFFFFE4CC), // melocotón
  Color(0xFFFFD9E6), // rosa
];

// Dentro de HabitEntity:
Color get cardColor {
  final index = id.codeUnits.fold<int>(0, (sum, code) => sum + code);
  return _kHabitCardColors[index % _kHabitCardColors.length];
}
```

**Racional**: Color es propiedad determinística del hábito. Mismo ID = mismo color siempre. No depende de tema ni contexto.

#### No se necesita `copyWith` nuevo — `cardColor` es getter computado, no campo.

---

### 3.2 Presentation Layer — `habits_provider.dart`

#### Nuevo enum (top-level, fuera de la clase)

```dart
enum HabitFilter { todos, completados, incompletos }
```

#### Nuevos campos en `HabitsProvider`

```dart
HabitFilter _activeFilter = HabitFilter.incompletos;
final Set<String> _completingIds = {};
final Set<String> _uncompletingIds = {};
String? _expandedHabitId;
```

#### Nuevos getters

```dart
HabitFilter get activeFilter => _activeFilter;
String? get expandedHabitId => _expandedHabitId;
bool isCompletingAnimation(String habitId) => _completingIds.contains(habitId);
bool isUncompletingAnimation(String habitId) => _uncompletingIds.contains(habitId);

List<HabitEntity> get filteredHabits {
  final visibleIds = _habits
      .where((h) {
        if (_completingIds.contains(h.id)) return true;
        if (_uncompletingIds.contains(h.id)) return true;
        switch (_activeFilter) {
          case HabitFilter.completados:
            return h.isCompletedToday;
          case HabitFilter.incompletos:
            return !h.isCompletedToday;
          case HabitFilter.todos:
            return true;
        }
      })
      .map((h) => h.id)
      .toSet();

  // Retorna todos los hábitos pero marca cuáles están "visibles"
  // El screen usa esto + Offstage para timed habits
  return List.unmodifiable(_habits);
}

// Getter auxiliar para IDs visibles (para Offstage pattern)
Set<String> get _visibleHabitIds {
  return _habits
      .where((h) {
        if (_completingIds.contains(h.id)) return true;
        if (_uncompletingIds.contains(h.id)) return true;
        switch (_activeFilter) {
          case HabitFilter.completados:
            return h.isCompletedToday;
          case HabitFilter.incompletos:
            return !h.isCompletedToday;
          case HabitFilter.todos:
            return true;
        }
      })
      .map((h) => h.id)
      .toSet();
}

bool isHabitVisible(String habitId) => _visibleHabitIds.contains(habitId);
```

#### Nuevos métodos

```dart
void setFilter(HabitFilter filter) {
  if (_activeFilter == filter) return;
  _activeFilter = filter;
  notifyListeners();
}

void toggleExpanded(String habitId) {
  _expandedHabitId = _expandedHabitId == habitId ? null : habitId;
  notifyListeners();
}

void triggerCompletionAnimation(String habitId) {
  _completingIds.add(habitId);
  notifyListeners();
  Future.delayed(const Duration(milliseconds: 600), () {
    _completingIds.remove(habitId);
    notifyListeners();
  });
}

void triggerUncompletionAnimation(String habitId) {
  _uncompletingIds.add(habitId);
  notifyListeners();
  Future.delayed(const Duration(milliseconds: 600), () {
    _uncompletingIds.remove(habitId);
    notifyListeners();
  });
}
```

---

### 3.3 Presentation Layer — Nuevos Widgets

#### 3.3.1 `HabitSectionHeader`

```dart
// features/habits/presentation/widgets/habits/habit_section_header.dart

class HabitSectionHeader extends StatelessWidget {
  const HabitSectionHeader({super.key, required this.onCreateTap});

  final VoidCallback onCreateTap;

  @override
  Widget build(BuildContext context) {
    // Usa AppTextStyles.titleLarge(context)
    // Usa AppColors para colores del botón crear
    // Row: "Tus hábitos" | FilterBar | CreateHabitButton
  }
}
```

#### 3.3.2 `HabitFilterBar`

```dart
// features/habits/presentation/widgets/habits/habit_filter_bar.dart

class HabitFilterBar extends StatelessWidget {
  const HabitFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Selector<HabitsProvider, HabitFilter> para activeFilter
    // 3x AnimatedFilterChip con provider.setFilter()
  }
}
```

#### 3.3.3 `CreateHabitButton`

```dart
// features/habits/presentation/widgets/habits/create_habit_button.dart

class CreateHabitButton extends StatelessWidget {
  const CreateHabitButton({super.key});

  @override
  Widget build(BuildContext context) {
    // Container circular con HugeIcon
    // Colores via AppColors.darkPrimary / AppColors.lightPrimary
    // onTap → showModalBottomSheet (extraer también el sheet a CreateHabitSheet)
  }
}
```

#### 3.3.4 `CreateHabitSheet`

```dart
// features/habits/presentation/widgets/habits/create_habit_sheet.dart

class CreateHabitSheet extends StatelessWidget {
  const CreateHabitSheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Contenido del bottom sheet
    // Usa AppTextStyles.h3(context) para título
    // Usa AppTextStyles.bodyMedium(context) para descripción
  }
}
```

#### 3.3.5 `HabitListSection` (reemplaza _HabitsSection)

```dart
// features/habits/presentation/widgets/habits/habit_list_section.dart

class HabitListSection extends StatelessWidget {
  const HabitListSection({super.key});

  @override
  Widget build(BuildContext context) {
    // Selector para filteredHabits
    // Column: HabitSectionHeader + empty state + lista de HabitCardWrapper
  }
}
```

#### 3.3.6 `HabitCardWrapper`

```dart
// features/habits/presentation/widgets/habits/habit_card_wrapper.dart

class HabitCardWrapper extends StatelessWidget {
  const HabitCardWrapper({required this.habit, super.key});

  final HabitEntity habit;

  @override
  Widget build(BuildContext context) {
    // Selector para: isExpanded, isCompleting, isUncompleting, activeFilter
    // Calcula shouldFade, shouldSlideBack
    // Offstage para timed habits
    // AnimatedOpacity + AnimatedSlide + GestureDetector
    // Delega a _buildCardByType (switch en trackingType)
  }

  Widget _buildCardByType(BuildContext context, HabitEntity habit) {
    // switch (habit.trackingType) → TimedHabitItemCard / OneTimeHabitItemCard / CounterHabitItemCard
    // habit.cardColor en lugar de _colorFor(habit.id)
    // Callbacks via provider methods
  }
}
```

#### 3.3.7 `HabitEmptyState`

```dart
// features/habits/presentation/widgets/habits/habit_empty_state.dart

class HabitEmptyState extends StatelessWidget {
  const HabitEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    // Text "No hay hábitos para este filtro."
    // Usa AppTextStyles.bodySmall(context)
    // Usa Theme.of(context).colorScheme.onSurfaceVariant
  }
}
```

---

### 3.4 Presentation Layer — `habits_redesign_screen.dart` (Refactored)

```dart
class HabitsRedesignScreen extends StatelessWidget {
  const HabitsRedesignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureLayout(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TodayProgressCard(),
                WeeklyHabitsStatistics(),
                SizedBox(height: 8),
                HabitListSection(),    // ← nuevo
                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

**La screen se reduce a ~30 líneas.** Todo delegado a widgets.

---

## 4. Nuevas Clases Widget — Resumen

| Clase | Tipo | Responsabilidad | Reemplaza |
|-------|------|-----------------|-----------|
| `HabitSectionHeader` | StatelessWidget | Título + FilterBar + CreateButton | Inline en `_HabitsSection.build` |
| `HabitFilterBar` | StatelessWidget | 3 chips de filtro | `_AnimatedFilterChip` x3 inline |
| `CreateHabitButton` | StatelessWidget | Botón circular "+" | GestureDetector + Container inline |
| `CreateHabitSheet` | StatelessWidget | Bottom sheet contenido | Builder inline del modal |
| `HabitListSection` | StatelessWidget | Sección completa de hábitos | `_HabitsSection` |
| `HabitCardWrapper` | StatelessWidget | Card individual con animaciones | `_buildHabitCard` |
| `HabitEmptyState` | StatelessWidget | Mensaje lista vacía | Padding + Text inline |
| `AnimatedFilterChip` | StatelessWidget | Chip animado (ya existe, hacer público) | `_AnimatedFilterChip` → `AnimatedFilterChip` |

---

## 5. Optimizaciones de Performance

### 5.1 Selector en lugar de watch

**Antes (rebuilda todo):**
```dart
final provider = context.watch<HabitsProvider>();
```

**Después (rebuild selectivo):**
```dart
// En HabitFilterBar — solo rebuilda cuando cambia el filtro
final activeFilter = context.select<HabitsProvider, HabitFilter>(
  (p) => p.activeFilter,
);

// En HabitCardWrapper — solo rebuilda cuando cambia el estado de ESTE hábito
final isExpanded = context.select<HabitsProvider, bool>(
  (p) => p.expandedHabitId == habit.id,
);

final isCompleting = context.select<HabitsProvider, bool>(
  (p) => p.isCompletingAnimation(habit.id),
);

// En HabitListSection — solo rebuilda cuando cambia la lista filtrada
final habits = context.select<HabitsProvider, List<HabitEntity>>(
  (p) => p.filteredHabits,
);
```

### 5.2 Const constructors

Todos los nuevos widgets deben tener `const` constructors. Los widgets hijos que no dependen de estado dinámico deben ser `const`:

```dart
const SizedBox(height: 12),  // ✅
const HabitEmptyState(),     // ✅ si no tiene params dinámicos
```

### 5.3 Rebuild boundaries

```
HabitsRedesignScreen (no rebuilda)
├── TodayProgressCard (Selector → solo rebuilda con progress)
├── WeeklyHabitsStatistics (Selector → solo rebuilda con stats)
└── HabitListSection (Selector → rebuilda con filteredHabits)
    ├── HabitSectionHeader (no rebuilda con datos de hábitos)
    │   ├── HabitFilterBar (Selector → solo rebuilda con activeFilter)
    │   └── CreateHabitButton (nunca rebuilda)
    ├── HabitEmptyState (condicional)
    └── HabitCardWrapper x N (Selector → cada uno rebuilda solo con SU estado)
```

### 5.4 Offstage pattern preservado

```dart
// En HabitCardWrapper.build:
final isVisible = context.select<HabitsProvider, bool>(
  (p) => p.isHabitVisible(habit.id),
);

if (habit.trackingType == HabitTrackingType.timed) {
  return Offstage(
    key: ValueKey('os_${habit.id}'),
    offstage: !isVisible,
    child: _buildCardByType(context, habit),
  );
}

if (!isVisible) return const SizedBox.shrink();
return _buildCardByType(context, habit);
```

**Importante**: El `provider.habits` original se itera (no `filteredHabits`) para mantener todos los timed habits en el tree. `isHabitVisible` determina si están offstage o no.

---

## 6. Plan de Acción — File by File

### Orden de ejecución (dependencias primero)

| Paso | Archivo | Acción | Riesgo |
|------|---------|--------|--------|
| 1 | `habit_entity.dart` | Agregar getter `cardColor` + constante `_kHabitCardColors` | Bajo — solo agrega getter |
| 2 | `habits_provider.dart` | Agregar enum `HabitFilter`, campos, getters, métodos | Medio — afecta todos los consumers |
| 3 | `app_colors.dart` | Agregar lista `habitCardColors` si se decide moverlos aquí | Bajo — opcional |
| 4 | `animated_filter_chip.dart` | Renombrar `_AnimatedFilterChip` → `AnimatedFilterChip`, hacer público | Bajo — solo renombrar |
| 5 | `create_habit_button.dart` | Crear nuevo archivo | Bajo — nuevo archivo |
| 6 | `create_habit_sheet.dart` | Crear nuevo archivo | Bajo — nuevo archivo |
| 7 | `habit_filter_bar.dart` | Crear nuevo archivo | Bajo — nuevo archivo |
| 8 | `habit_section_header.dart` | Crear nuevo archivo | Bajo — nuevo archivo |
| 9 | `habit_empty_state.dart` | Crear nuevo archivo | Bajo — nuevo archivo |
| 10 | `habit_card_wrapper.dart` | Crear nuevo archivo (el más complejo) | Alto — contiene lógica de animación + Offstage |
| 11 | `habit_list_section.dart` | Crear nuevo archivo | Medio — orquesta los demás |
| 12 | `habits_redesign_screen.dart` | Reducir a shell que usa `HabitListSection` | Bajo — solo simplificar |

### Detalle por paso

#### Paso 1: `habit_entity.dart`

```dart
// Agregar al inicio del archivo, antes de la clase:
import 'package:flutter/material.dart';

const _kHabitCardColors = [
  Color(0xFFDFFECF),
  Color(0xFFD6F5FF),
  Color(0xFFE8D8FF),
  Color(0xFFFFE4CC),
  Color(0xFFFFD9E6),
];

// Agregar dentro de HabitEntity, después del getter `streak`:
Color get cardColor {
  final index = id.codeUnits.fold<int>(0, (sum, code) => sum + code);
  return _kHabitCardColors[index % _kHabitCardColors.length];
}
```

#### Paso 2: `habits_provider.dart`

```dart
// Agregar después de los imports:
enum HabitFilter { todos, completados, incompletos }

// Agregar campos después de _syncProvider:
HabitFilter _activeFilter = HabitFilter.incompletos;
final Set<String> _completingIds = {};
final Set<String> _uncompletingIds = {};
String? _expandedHabitId;

// Agregar getters después de `hasError`:
HabitFilter get activeFilter => _activeFilter;
String? get expandedHabitId => _expandedHabitId;
bool isCompletingAnimation(String habitId) => _completingIds.contains(habitId);
bool isUncompletingAnimation(String habitId) => _uncompletingIds.contains(habitId);

Set<String> get _visibleHabitIds {
  return _habits.where((h) {
    if (_completingIds.contains(h.id)) return true;
    if (_uncompletingIds.contains(h.id)) return true;
    switch (_activeFilter) {
      case HabitFilter.completados:
        return h.isCompletedToday;
      case HabitFilter.incompletos:
        return !h.isCompletedToday;
      case HabitFilter.todos:
        return true;
    }
  }).map((h) => h.id).toSet();
}

List<HabitEntity> get filteredHabits => List.unmodifiable(_habits);
bool isHabitVisible(String habitId) => _visibleHabitIds.contains(habitId);

// Agregar métodos después de `deleteHabit`:
void setFilter(HabitFilter filter) {
  if (_activeFilter == filter) return;
  _activeFilter = filter;
  notifyListeners();
}

void toggleExpanded(String habitId) {
  _expandedHabitId = _expandedHabitId == habitId ? null : habitId;
  notifyListeners();
}

void triggerCompletionAnimation(String habitId) {
  _completingIds.add(habitId);
  notifyListeners();
  Future.delayed(const Duration(milliseconds: 600), () {
    _completingIds.remove(habitId);
    notifyListeners();
  });
}

void triggerUncompletionAnimation(String habitId) {
  _uncompletingIds.add(habitId);
  notifyListeners();
  Future.delayed(const Duration(milliseconds: 600), () {
    _uncompletingIds.remove(habitId);
    notifyListeners();
  });
}
```

#### Paso 3-11: Crear nuevos archivos

Cada archivo sigue patrón:
- Import solo lo necesario
- `const` constructor
- Usa `AppTextStyles` y `AppColors`
- Usa `Selector` para estado del provider

#### Paso 12: `habits_redesign_screen.dart`

Reducir a:
```dart
import '...';

class HabitsRedesignScreen extends StatelessWidget {
  const HabitsRedesignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureLayout(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TodayProgressCard(),
            WeeklyHabitsStatistics(),
            SizedBox(height: 8),
            HabitListSection(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
```

---

## 7. Evaluación de Riesgos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| **R1**: Animaciones de completado se pierden al cambiar filtro | Media | Alto | `_completingIds` en provider sobrevive rebuilds. El `HabitCardWrapper` consulta `isCompletingAnimation(id)` via Selector |
| **R2**: Timed habits pierden estado del timer con Offstage | Baja | Crítico | Offstage preserva state del widget tree. Verificar que `key: ValueKey('os_${habit.id}')` se mantiene |
| **R3**: Rebuilds excesivos si Selector no se usa bien | Media | Medio | Cada widget usa `select` con función lo más específica posible. No usar `select` con funciones que crean objetos nuevos |
| **R4**: `notifyListeners` frecuente causa jank | Media | Medio | Animations usan `Future.delayed` con 2 notifyListeners. Considerar agrupar si hay jank |
| **R5**: `cardColor` en entity rompe tests existentes | Baja | Bajo | Solo agrega getter. No cambia estructura. Tests existentes siguen pasando |
| **R6**: Enum `HabitFilter` colisiona con `_HabitFilter` antiguo | Baja | Bajo | Se elimina `_HabitFilter` al migrar. No coexisten |
| **R7**: Provider crece demasiado (ya 657 líneas) | Media | Bajo | Estado de UI (filter, expanded, animations) pertenece al provider en este patrón. Si crece >800 líneas, considerar `HabitUiProvider` separado |

### Mitigaciones Clave

1. **R1 (Animaciones)**: Los IDs animados están en provider. El widget solo consulta estado. Si filtro cambia durante animación, el widget se reconstruye con estado correcto.

2. **R2 (Offstage)**: Patrón existente se preserva. `Offstage` no destruye el widget, solo lo oculta. El timer interno del `TimedHabitItemCard` sobrevive.

3. **R3 (Rebuilds)**: Regla: `select` con getter simple, nunca con computación inline. Si necesitas computar, crea getter en provider.

---

## 8. Estructura Final de Archivos

```
features/habits/
├── domain/
│   └── entities/
│       └── habit_entity.dart          # + cardColor getter
├── presentation/
│   ├── providers/
│   │   └── habits_provider.dart       # + filter state, animation state, methods
│   ├── screens/
│   │   └── habits_redesign_screen.dart # → ~30 líneas, solo shell
│   └── widgets/
│       └── habits/
│           ├── animated_filter_chip.dart    # (renombrado de _AnimatedFilterChip)
│           ├── create_habit_button.dart     # (nuevo)
│           ├── create_habit_sheet.dart      # (nuevo)
│           ├── habit_filter_bar.dart        # (nuevo)
│           ├── habit_section_header.dart    # (nuevo)
│           ├── habit_empty_state.dart       # (nuevo)
│           ├── habit_card_wrapper.dart      # (nuevo, más complejo)
│           ├── habit_list_section.dart      # (nuevo, orquestador)
│           ├── counter_habit_item_card/     # (existente, sin cambios)
│           ├── one_time_habit_item_card/    # (existente, sin cambios)
│           └── timed_habit_item_card/       # (existente, sin cambios)
```

---

## 9. Criterios de Éxito

- [ ] `habits_redesign_screen.dart` < 50 líneas
- [ ] Cero method-widgets (ningún método que retorne Widget)
- [ ] Todos los widgets nuevos tienen `const` constructor
- [ ] `HabitEntity.cardColor` retorna color determinístico por ID
- [ ] `HabitsProvider` tiene `HabitFilter`, `setFilter`, `toggleExpanded`, animación methods
- [ ] `Selector` usado en lugar de `watch` en todos los widgets hijos
- [ ] Todos los colores via `AppColors` o `habit.cardColor`
- [ ] Todos los textos via `AppTextStyles`
- [ ] App compila sin errores
- [ ] Animaciones de completado funcionan post-refactor
- [ ] Timed habits preservan estado del timer
- [ ] Filtro filtra correctamente los 3 modos
- [ ] `flutter analyze` sin warnings

# ACTIVE_CONTEXT.md — Memoria de Trabajo

> **INSTRUCCIÓN PARA EL AGENTE**: Este archivo es tu estado mental del proyecto. Al inicio de cada sesión, léelo y verifica que su contenido coincide con el estado real del código. Si hay discrepancias, corrígelas. Al finalizar cualquier cambio significativo, actualiza este archivo antes de reportar al usuario.

_Última actualización: 2026-04-27 — Card de hábito: expandible vacío_

---

## Foco Actual

**Feature/Tarea**: UI polish — expandible al tocar card (`OneTimeHabitItemCard`).

**Descripción**: Tap en card (cualquier zona) alterna expand/collapse; muestra sección expandida vacía debajo del botón separada por `Divider` y animada con `AnimatedCrossFade`. Botón de completar NO expande.

**Estado**: ✅ Completo. Validado con `flutter analyze`: 0 issues.

---

## Estado del Proyecto por Feature

| Feature | Capa Domain | Capa Data | Capa Presentation | Tests |
|---|---|---|---|---|
| **Auth** | ✅ Completo | ✅ Completo | ✅ Completo | ✅ UseCases cubiertos |
| **Habits** | ✅ Completo | ✅ Completo | ✅ Completo | ✅ UseCases + Provider |
| **Notes** | ❌ No implementado | ❌ No implementado | 🚧 Placeholder (SoonWidget) | ❌ Sin tests |
| **Tasks** | ❌ No implementado | ❌ No implementado | 🚧 Placeholder (SoonWidget) | ❌ Sin tests |
| **Profile** | ❌ No implementado | ❌ No implementado | 🚧 Placeholder (SoonWidget) | ❌ Sin tests |

---

## Bloqueos Activos (Blockers)

_Ninguno conocido al momento de inicialización._

> Si encuentras un blocker en sesión, documéntalo aquí con este formato:
> **[BLOCKER]** `<descripción>` — Impacto: `<alto/medio/bajo>` — Reportado: `<fecha>`

---

## Decisiones Pendientes

- [ ] Definir threshold de `retry_count` en `SyncService` antes de abandonar un item de sync.
- [x] ✅ Migrar queries de `sqflite` a `drift` puro — Completado 2026-04-24 (commit `50f396a`).
- [ ] Evaluar implementación de `home_widget` (dependencia instalada pero sin uso visible).
- [ ] Definir diseño de features Notes y Tasks (no hay spec).

---

## Próximos Pasos (Next Actions)

Ordenados por prioridad:

1. **Verificar sync service**: Revisar `lib/core/services/sync_service.dart` — confirmar que retry_count tiene lógica de backoff y límite definido.
2. ~~**Completar migración a Drift**~~ — ✅ Completado 2026-04-24.
3. **Aumentar cobertura de tests**: DataSources local y remoto no tienen tests. Agregar tests para `HabitsLocalDatasourceImpl`.
4. **Implementar feature Notes o Tasks**: Elegir una para el próximo sprint. Seguir estructura de `habits/` como template.
5. **Profile screen**: Conectar con datos reales del usuario via `GetCurrentUserUseCase`.

---

## Contexto Técnico Activo

- **Branch actual**: `main`
- **Último commit**: `50f396a` — Migración sqflite → Drift (2026-04-24)
- **Cambio en sesión** (sin commit aún):
  - Editado: `lib/shared/presentation/widgets/app_bar/app_bar.dart` (header dinámico por pantalla)
  - Editado: `lib/shared/presentation/widgets/app_shell.dart` (pasa `currentIndex` al app bar)
  - Editado: `lib/shared/presentation/widgets/app_bar/app_bar.dart` (Fraunces solo en título)
  - Editado: `lib/features/habits/presentation/screens/habits_redesign_screen.dart` (degradado oscuro→claro en tarjeta `TodayProgress`)
  - Editado: `lib/features/habits/presentation/screens/habits_redesign_screen.dart` (contador `3/5` unificado con `Text.rich` para alineación en baseline)
  - Editado: `lib/features/habits/presentation/screens/habits_redesign_screen.dart` (removido `_TodayProgress`; usa `TodayProgressCard`)
  - Creado: `lib/features/habits/presentation/widgets/today_progress_card.dart` (UI + datos reales de progreso diario con `context.select`)
  - Editado: `lib/features/habits/presentation/widgets/today_progress_card.dart` (barra de progreso migrada a `LinearProgressIndicator` con mayor contraste)
  - Editado: `lib/features/habits/presentation/providers/habits_provider.dart` (nuevo getter `todayProgressSummary` + value object `TodayProgressSummary`)
  - Editado: `lib/features/habits/presentation/widgets/today_progress_card.dart` (elimina agregación local; consume `provider.todayProgressSummary`)
  - Editado: `lib/features/habits/presentation/widgets/today_progress_card.dart` (gradiente y color de total hábitos adaptados a tema claro/oscuro)
  - Editado: `lib/features/habits/presentation/screens/habits_redesign_screen.dart` (implementado `_StatisticsHabitsCustom` con columnas L-D y pastillas activas/inactivas según hábitos completados por día)
  - Editado: `lib/features/habits/presentation/providers/habits_provider.dart` (nuevo getter `weeklyHabitsStatsSummary` + value object `WeeklyHabitsStatsSummary`)
  - Creado: `lib/features/habits/presentation/widgets/weekly_habits_statistics.dart` (widget semanal desacoplado que consume snapshot del provider)
  - Editado: `lib/features/habits/presentation/screens/habits_redesign_screen.dart` (reemplaza `_StatisticsHabitsCustom` por `WeeklyHabitsStatistics`)
  - Editado: `lib/features/habits/presentation/screens/habits_redesign_screen.dart` (removido `_HabitItemCard`; ahora usa `OneTimeHabitItemCard` importado)
  - Creado: `lib/features/habits/presentation/widgets/habits/one_time_habit_item_card.dart` (widget dedicado para hábito de una sola vez)
  - Editado: `lib/features/habits/presentation/widgets/habits/one_time_habit_item_card.dart` (constructor con parámetros `emoji`, `title`, `description`, `streakDays`, `onExpandTap`, `onMarkCompletedTap`, `actionLabel`)
  - Editado: `lib/features/habits/presentation/screens/habits_redesign_screen.dart` (cards de ejemplo ahora pasan parámetros requeridos)
  - Editado: `lib/config/theme/app_colors.dart` (helper theme-aware `oneTimeHabitCardColor` para superficie pastel de hábitos)
  - Editado: `lib/features/habits/presentation/widgets/habits/one_time_habit_item_card.dart` (color de card configurable vía `cardColor` con fallback a `AppColors.oneTimeHabitCardColor`; expandTap quedó encapsulado en el widget)
  - Editado: `lib/features/habits/presentation/screens/habits_redesign_screen.dart` (cards de ejemplo ahora usan colores pastel distintos para comparar visualmente)
  - Editado: `lib/features/habits/presentation/widgets/habits/one_time_habit_item_card.dart` (botón "Marcar como completado" aclarado en light; borde suavizado en dark para evitar filtro gris)
  - Editado: `lib/features/habits/presentation/widgets/habits/one_time_habit_item_card.dart` (card dark ahora mezcla color con `surfaceContainer`/`surface`; botón light tiene sombra y relleno más visible)
  - Editado: `lib/features/habits/presentation/widgets/habits/one_time_habit_item_card.dart` (emoji box ya no usa verde fijo; ahora deriva del color smart y tiene borde propio)
  - Editado: `lib/features/habits/presentation/widgets/habits/one_time_habit_item_card.dart` (borde del botón en dark ajustado y sombras de card/botón aumentadas en light)
  - Editado: `lib/features/habits/presentation/widgets/habits/one_time_habit_item_card.dart` (modo oscuro pasa a mezclas con `Color.lerp` para levantar saturación; botón dark usa borde más legible)
  - Editado: `lib/features/habits/presentation/widgets/habits/one_time_habit_item_card.dart` (dark: sube mezcla hacia `resolvedCardColor` para colores más vivos)
  - Editado: `lib/features/habits/presentation/widgets/habits/one_time_habit_item_card.dart` (tap card expande/colapsa; sección expandida vacía + divider)

---

## Notas de Sesión

_Usar esta sección para notas temporales de la sesión actual. Limpiar al finalizar._

- **Sesión 2026-04-24 (1)**: Migración sqflite → Drift completada. Aprendizaje: trabajé en worktree sin darlo cuenta. Próxima: verificar `pwd` y branch al inicio. Preferencia: editar directo en `main/`, no en worktrees.
- **Sesión 2026-04-24 (2)**: Rediseño SoonWidget al estilo appbar/navbar. Aprendizaje: actualizar ACTIVE_CONTEXT.md al final de cada cambio significativo — no omitirlo.
- **Sesión 2026-04-26 (1)**: MainAppBar ahora muestra título/subtítulo por módulo y los oculta en rutas hijas. Verificado con `flutter analyze` en archivos tocados (0 issues).
- **Sesión 2026-04-26 (2)**: Ajuste tipográfico solicitado: Fraunces aplicada únicamente al título de AppBar; descripción sin cambios.
- **Sesión 2026-04-26 (3)**: En `HabitsRedesignScreen`, tarjeta `TodayProgress` ahora usa degradado horizontal entre `Color(0xFF135970)` y `Color(0xFF30B5CE)` con predominio visual del tono oscuro (`stops: [0.0, 0.85]`). Verificado con analyzer del archivo (0 issues).
- **Sesión 2026-04-26 (4)**: En `HabitsRedesignScreen`, reemplazo de `Row` con dos `Text` por `Text.rich` + `TextSpan` para contador `3/5`, manteniendo estilos distintos y alineación tipográfica en una sola línea.
- **Sesión 2026-04-26 (5)**: `TodayProgress` extraído a widget dedicado (`TodayProgressCard`) en `presentation/widgets/`; ahora consume datos reales (`completados/total`, `% completado`, barra de progreso) desde `HabitsProvider` con `context.select` para minimizar reconstrucciones.
- **Sesión 2026-04-26 (6)**: Ajuste de visibilidad de barra en `TodayProgressCard`: reemplazo de barra custom por `LinearProgressIndicator` con pista más contrastada (`alpha: 0.42`) para que se vea incluso en progreso bajo/cero.
- **Sesión 2026-04-26 (7)**: Cálculo agregado de progreso diario movido al provider (`todayProgressSummary`). `TodayProgressCard` ahora sólo renderiza y escucha ese snapshot tipado con `context.select`.
- **Sesión 2026-04-26 (8)**: Ajuste de contraste por tema en `TodayProgressCard`: opacidades del degradado y color del texto de hábitos totales varían entre modo claro/oscuro para mejorar legibilidad.
- **Sesión 2026-04-26 (9)**: Implementado `_StatisticsHabitsCustom` en `HabitsRedesignScreen`: visual semanal por columnas (L-D), highlight del día actual y 4 pastillas por día; cada pastilla activa representa hábitos con meta diaria cumplida en ese día, inactivas en gris tenue.
- **Sesión 2026-04-26 (10)**: Removida animación del visual semanal en `HabitsRedesignScreen`: `AnimatedContainer` reemplazado por `Container` para etiqueta de día sin transición.
- **Sesión 2026-04-26 (11)**: Refactor de fluidez UI: visual semanal extraído a `weekly_habits_statistics.dart`; cálculo semanal movido a `HabitsProvider` (`weeklyHabitsStatsSummary`) para que widget solo renderice snapshot via `context.select`.
- **Sesión 2026-04-26 (12)**: Optimización de rebuilds en `weekly_habits_statistics.dart`: composición en subwidgets (`_WeekDayColumn`, `_WeeklyPill`) y `Selector<HabitsProvider, bool>` por píldora para reconstrucción granular (cambia una píldora, no todo el grid).
- **Sesión 2026-04-27 (1)**: En `HabitsRedesignScreen`, extracción de tarjeta de hábito a archivo propio dentro de `widgets/habits/`; renombrado a `OneTimeHabitItemCard` para representar explícitamente tipo de hábito "de una sola vez".
- **Sesión 2026-04-27 (2)**: `OneTimeHabitItemCard` convertido a widget parametrizable para soportar datos dinámicos por hábito (emoji, título, descripción, racha y callbacks); `HabitsRedesignScreen` actualizado con instancias de ejemplo usando esos parámetros.
- **Sesión 2026-04-27 (3)**: `AppColors` recibió helper theme-aware para superficie pastel de hábito de una sola vez; `OneTimeHabitItemCard` usa fallback inteligente y mantiene `expandTap` encapsulado sin callback externo.
- **Sesión 2026-04-27 (4)**: En `HabitsRedesignScreen`, instancias de `OneTimeHabitItemCard` usan colores pastel distintos por card para validar visualmente contraste y look general.
- **Sesión 2026-04-27 (5)**: Ajuste fino de contraste en `OneTimeHabitItemCard`: el botón de completar usa relleno pastel en modo claro y el borde en modo oscuro perdió intensidad para evitar apariencia de capa gris.
- **Sesión 2026-04-27 (6)**: Replanteo de mezcla de color en `OneTimeHabitItemCard`: en modo oscuro se usa `Color.alphaBlend` sobre `surfaceContainer/surface` para evitar borde/fondo lavados; en modo claro el botón gana sombra para hacerse visible.
- **Sesión 2026-04-27 (7)**: Ajuste visual final en `OneTimeHabitItemCard`: el emoji ya no depende de verde fijo, el botón dark usa borde distinto y en light subió la sombra de card y botón para mejorar presencia.
- **Sesión 2026-04-27 (9)**: `OneTimeHabitItemCard` ahora anima la tarjeta completa con `AnimatedScale` al tap; el botón interno quedó sin animación propia.
- **Sesión 2026-04-27 (10)**: Ajuste de color en dark para `OneTimeHabitItemCard`: aumenta contribución del `cardColor` en fondos (card/emoji/botón) para evitar look opaco. Validado con `flutter analyze` (0 issues).
- **Sesión 2026-04-27 (11)**: `OneTimeHabitItemCard` ahora es expandible: tap en card alterna `_isExpanded` y renderiza bloque vacío bajo el botón con `Divider` (animado con `AnimatedCrossFade`). Botón de completar no alterna expansión. Validado con `flutter analyze` (0 issues).

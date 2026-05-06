# ACTIVE_CONTEXT.md — Memoria de Trabajo

> **INSTRUCCIÓN PARA EL AGENTE**: Este archivo es tu estado mental del proyecto. Al inicio de cada sesión, léelo y verifica que su contenido coincide con el estado real del código. Si hay discrepancias, corrígelas. Al finalizar cualquier cambio significativo, actualiza este archivo antes de reportar al usuario.

_Última actualización: 2026-05-05 — CreateHabitSheet refactorizado a Clean Architecture + Performance_

---

## Foco Actual

**Feature/Tarea**: CreateHabitSheet refactor — Clean Architecture + Performance.

**Descripción**:
- `CreateHabitSheet` extraído a carpeta dedicada `create_habit_sheet/` con 6 widgets independientes.
- Conexión a `NewHabitProvider` (remove estado duplicado: controllers, tracking type).
- `TrackingTypeOptionCard` usa `context.select` para rebuild granular.
- `HabitSheetTextField` unifica campos nombre/descripción (elimina ~60 líneas duplicadas).
- `const` constructores en todos los widgets.
- Zero info/warnings en `lib/`.

**Estado**: ✅ Completado y validado con `flutter analyze` (0 errors en lib/).

---

## Estado del Proyecto por Feature

| Feature | Capa Domain | Capa Data | Capa Presentation | Tests |
|---|---|---|---|---|
| **Auth** | ✅ Completo | ✅ Completo | ✅ Completo | ✅ UseCases cubiertos |
| **Habits** | ✅ Completo | ✅ Completo | ✅ Refactorizado | ✅ Tests existentes OK |
| **Notes** | ❌ No implementado | ❌ No implementado | 🚧 Placeholder (SoonWidget) | ❌ Sin tests |
| **Tasks** | ❌ No implementado | ❌ No implementado | 🚧 Placeholder (SoonWidget) | ❌ Sin tests |
| **Profile** | ❌ No implementado | ❌ No implementado | 🚧 Placeholder (SoonWidget) | ❌ Sin tests |

---

## Archivos Modificados/Creados (CreateHabitSheet Refactor)

| Archivo | Acción |
|---|---|
| `lib/features/habits/presentation/widgets/habits/create_habit_sheet/` | Carpeta nueva |
| `lib/features/habits/presentation/widgets/habits/create_habit_sheet/create_habit_sheet.dart` | Nuevo — orquestador con Provider |
| `lib/features/habits/presentation/widgets/habits/create_habit_sheet/habit_sheet_title.dart` | Nuevo — título "Nuevo hábito" |
| `lib/features/habits/presentation/widgets/habits/create_habit_sheet/name_description_toggle.dart` | Nuevo — control segmentado |
| `lib/features/habits/presentation/widgets/habits/create_habit_sheet/habit_sheet_text_field.dart` | Nuevo — TextField reutilizable |
| `lib/features/habits/presentation/widgets/habits/create_habit_sheet/tracking_type_option_card.dart` | Nuevo — card animada con Selector |
| `lib/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_tracking_type_row.dart` | Nuevo — fila de 3 opciones |
| `lib/features/habits/presentation/widgets/habits/create_habit_sheet.dart` | Eliminado (monolítico, 351 líneas) |
| `lib/features/habits/presentation/widgets/habits/create_habit_button.dart` | Modificado — import actualizado |

---

## Decisiones Pendientes

- [x] ✅ SDD Habits Module Full Stack Refactor v2 aplicado.
- [ ] Evaluar implementación de `home_widget`.
- [ ] Definir diseño de features Notes y Tasks.

---

## Próximos Pasos (Next Actions)

1. **Implementar feature Notes o Tasks**: Elegir una para próximo sprint.
2. **Evaluar implementación de `home_widget`**.
3. **Definir diseño de features Notes y Tasks**.
4. **Correr tests**: `flutter test` para validar todo sigue funcionando.

---

## Contexto Técnico Activo

- **Branch actual**: `main`
- **Cambio en sesión**: SDD v2 implementado — 10 archivos modificados/creados.
- **Validación**: `flutter analyze` sin errors en lib/.

---

## Notas de Sesión

- **2026-05-05 (Sesión 1)**: SDD Habits Full Stack Refactor v2 aplicado. 6 defectos corregidos (C1-C6). `flutter analyze` limpio.
- **2026-05-05 (Sesión 2)**: CreateHabitSheet refactorizado — 351 líneas monolíticas → 6 widgets en carpeta dedicada. Conectado a `NewHabitProvider` (elimina estado duplicado). `context.select` en TrackingTypeOptionCard para rebuilds granulares. `const` constructores en todos los widgets. `flutter analyze` 0 issues en lib/.
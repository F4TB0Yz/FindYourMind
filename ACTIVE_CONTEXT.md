# ACTIVE_CONTEXT.md — Memoria de Trabajo

> **INSTRUCCIÓN PARA EL AGENTE**: Este archivo es tu estado mental del proyecto. Al inicio de cada sesión, léelo y verifica que su contenido coincide con el estado real del código. Si hay discrepancias, corrígelas. Al finalizar cualquier cambio significativo, actualiza este archivo antes de reportar al usuario.

_Última actualización: 2026-05-06 — Pre-commit validation clean_

---

## Foco Actual

**Feature/Tarea**: CreateHabitSheet fixed title scroll body.

**Descripción**:
- `CreateHabitSheet` extraído a carpeta dedicada `create_habit_sheet/` con 6 widgets independientes.
- Conexión a `NewHabitProvider` (remove estado duplicado: controllers, tracking type).
- `TrackingTypeOptionCard` usa `context.select` para rebuild granular.
- `HabitSheetTextField` unifica campos nombre/descripción (elimina ~60 líneas duplicadas).
- `const` constructores en todos los widgets.
- Componentes de `create_habit_sheet/` usan `GoogleFonts` para textos; no queda `fontFamily: 'Plus Jakarta Sans'`.
- `sheet_icon_color_section.dart` limita el ancho del título con `Expanded` para evitar overflow contra el toggle de emoji/color.
- `sheet_tab_toggle.dart` ahora adapta el color del texto por brillo para mantener contraste en modo oscuro.
- `CreateHabitSheet` mantiene el título fijo arriba, con el cuerpo y footer al final del scroll.
- El bottom sheet permite guardar con `HabitCategory.none`; solo valida título y usuario autenticado.

**Estado**: ✅ Título fijo, footer en scroll y guardado aplicados. `flutter analyze` y `flutter test` pasan limpios.

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
| `lib/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_icon_color_section.dart` | Modificado — límite de ancho para el título de vista previa |
| `lib/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_tab_toggle.dart` | Modificado — contraste de texto adaptado a modo oscuro |
| `lib/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_footer_actions.dart` | Nuevo — footer con Cancelar/Guardar hábito al final del scroll |
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
- **Cambio en sesión**: Título fijo en `CreateHabitSheet`; cuerpo y footer quedan dentro del scroll con acciones Cancelar/Guardar y creación de hábito desde el bottom sheet.
- **Validación**: `flutter analyze` sin issues; `flutter test` pasa completo (100 tests).

---

## Notas de Sesión

- **2026-05-05 (Sesión 1)**: SDD Habits Full Stack Refactor v2 aplicado. 6 defectos corregidos (C1-C6). `flutter analyze` limpio.
- **2026-05-05 (Sesión 2)**: CreateHabitSheet refactorizado — 351 líneas monolíticas → 6 widgets en carpeta dedicada. Conectado a `NewHabitProvider` (elimina estado duplicado). `context.select` en TrackingTypeOptionCard para rebuilds granulares. `const` constructores en todos los widgets. `flutter analyze` 0 issues en lib/.
- **2026-05-06 (Sesión 1)**: Deuda técnica saldada en `CreateHabitSheet`. Implementado `dispose` correcto del listener de `titleController` almacenando referencia local. `flutter analyze` limpio.
- **2026-05-06 (Sesión 2)**: Auditoría de fuentes en `create_habit_sheet/`. Eliminado uso hardcodeado de `fontFamily: 'Plus Jakarta Sans'` en secciones timed/counter/icon-color/tab-toggle. Verificación `rg` limpia; `flutter analyze` conserva 24 issues existentes no relacionados.
- **2026-05-06 (Sesión 3)**: Fix de overflow en el preview del hábito. El título ahora vive dentro de `Expanded` y no invade el toggle de emoji/color. Validación de archivo sin errores.
- **2026-05-06 (Sesión 4)**: Bootstrap de localización Flutter aplicado. Agregado `flutter_localizations`, delegates y `Locale('es')` en `MaterialApp.router`. `flutter test` completó OK.
- **2026-05-06 (Sesión 5)**: Ajuste de contraste en `SheetTabToggle` para mantener legibilidad del texto en modo oscuro. Validación puntual sin errores.
- **2026-05-06 (Sesión 6)**: Implementado footer de `CreateHabitSheet` al final del scroll con divider, botones Cancelar/Guardar hábito y funcionalidad de creación vía `HabitsProvider`. El título queda fijo arriba. Se permite `HabitCategory.none` en bottom sheet. Validación puntual limpia.
- **2026-05-06 (Sesión 7)**: Limpieza pre-commit para dejar validación global en verde. Corregidos analyzer issues en `app_database.dart`, `sheet_color_grid.dart` y tests. `graphify update .` ejecutado tras tocar código. `flutter analyze` y `flutter test` pasan.
- **2026-05-06 (Sesión 8)**: Validación inline del título en `CreateHabitSheet`. Reemplazado `CustomToast` por error inline debajo del campo. `HabitSheetTextField` ahora acepta `errorText` y muestra borde rojo + texto de error con `GoogleFonts.plusJakartaSans`. `flutter analyze` limpio.

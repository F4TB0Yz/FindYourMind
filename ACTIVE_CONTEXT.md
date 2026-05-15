# ACTIVE_CONTEXT.md — Memoria de Trabajo

> **INSTRUCCIÓN PARA EL AGENTE**: Este archivo es tu estado mental del proyecto. Al inicio de cada sesión, léelo y verifica que su contenido coincide con el estado real del código. Si hay discrepancias, corrígelas. Al finalizar cualquier cambio significativo, actualiza este archivo antes de reportar al usuario.

_Última actualización: 2026-05-14 — Profile screen settings sections_

---

## Foco Actual

**Feature/Tarea**: Profile screen — secciones de ajustes (Cuenta, Preferencias, Cerrar sesión).

**Descripción**:
- Nuevo widget `ProfileSettingsSection` + `ProfileSettingsItem` en `lib/features/profile/presentation/widgets/profile_settings_section.dart`.
- `ProBadge` (chip PRO teal) y `DarkModeToggle` (Switch conectado a `ThemeProvider`) en el mismo archivo.
- `profile_screen.dart` reemplaza el `Column` vacío con `_ProfileSettings` que renderiza las 3 secciones.
- Sección **Cuenta**: Plan (+ PRO badge), Editar perfil, Notificaciones.
- Sección **Preferencias**: Modo oscuro (toggle real), Recordatorios, Privacidad y datos.
- Sección standalone **Cerrar sesión** (destructive, con diálogo de confirmación).
- Ítems placeholder muestran Snackbar "Próximamente". Sign-out redirige automáticamente vía `_AuthChangeNotifier`.

**Estado**: ✅ `flutter analyze` 0 issues.

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

## Archivos Modificados/Creados (Tests en español + magenta)

| Archivo | Acción |
|---|---|
| `test/test_utils/test_output_style.dart` | Nuevo — helper `label(...)` para magenta ANSI con fallback (`NO_COLOR`, `TERM=dumb`) y soporte de `CI`/`FORCE_COLOR`. |
| `test/**` | Modificado — traducción de descripciones y envoltura `label(...)` en `group/test/testWidgets` (múltiples archivos). |
| `lib/features/profile/presentation/widgets/profile_header.dart` | Modificado — altura finita para evitar constraints infinitos en `Stack` dentro de scroll. |
| `lib/features/profile/presentation/widgets/profile_stats_row.dart` | Nuevo — fila de stats (racha, hábitos, cumplimiento) usando HabitsProvider + fuente Fraunces. |
| `lib/features/profile/presentation/screens/profile_screen.dart` | Modificado — incluye `ProfileStatsRow` + secciones de ajustes. |
| `lib/features/profile/presentation/widgets/profile_settings_section.dart` | Nuevo — `ProfileSettingsSection`, `ProfileSettingsItem`, `ProBadge`, `DarkModeToggle`. |

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
- **Cambio en sesión**: Fix de constraints infinitos en `ProfileHeader`.
- **Validación**: `flutter test` OK. `graphify update .` ejecutado.

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
- **2026-05-12 (Sesión 1)**: Traducción de descripciones de tests (`group/test/testWidgets`) a español y resaltado en magenta via helper ANSI (se activa en terminal con ANSI, o forzado con `CI`/`FORCE_COLOR`; se desactiva con `NO_COLOR`). `flutter test` OK. `graphify update .` ejecutado.
- **2026-05-12 (Sesión 2)**: Fix de `ProfileHeader` en `SingleChildScrollView`: se limita altura finita para evitar `BoxConstraints(w=..., h=Infinity)`. `flutter test` OK. `graphify update .` ejecutado.

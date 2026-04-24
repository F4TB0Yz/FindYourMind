# PROGRESS_LOG.md — Historial Inmutable

> **INSTRUCCIÓN PARA EL AGENTE**: Registro cronológico invertido (más nuevo arriba). Solo agregar entradas, nunca editar o borrar las existentes. Cada entrada representa trabajo fusionado a `main` o completado en producción. Este log previene que el agente intente reimplementar cosas que ya funcionan.

---

## Formato de Entrada

```
[YYYY-MM-DD] - <Tipo>: <Descripción concisa> — Archivos: <lista de archivos clave>
```

Tipos válidos: `Feature`, `Bugfix`, `Refactor`, `Infra`, `Test`, `Docs`

---

## Log

---

[2026-04-24] - Docs: Inicialización del Sistema de Memoria (Context Engineering) — Archivos: `CLAUDE.md`, `AGENTS.md`, `PROJECT_CONTEXT.md`, `ARCHITECTURAL_DECISIONS.md`, `ACTIVE_CONTEXT.md`, `PROGRESS_LOG.md`

---

[2026-04-24] - Feature: Unificación de navegación global y rediseño del MainFab — Archivos: `lib/shared/presentation/widgets/app_shell.dart`, `lib/shared/presentation/widgets/fab/main_fab.dart`, `lib/shared/presentation/widgets/bottom_nav_bar/custom_bottom_bar.dart`

---

[2026-04-24] - Refactor: Simplificación de layout — eliminación de contenedores border redundantes, actualización de FeatureLayout — Archivos: `lib/shared/presentation/widgets/layouts/feature_layout.dart`

---

[2026-04-24] - Refactor: Fix de lints en tests, constantes en entidades, mejoras de calidad de código — Archivos: `test/**/*_test.dart`, `lib/features/habits/domain/entities/*.dart`

---

[2026-04-24] - Refactor: Eliminación de constantes de auth hardcodeadas, integración con sistema de auth real — Archivos: `lib/core/services/auth_service.dart`, `lib/core/services/supabase_auth_service.dart`, `lib/features/auth/presentation/providers/auth_providers.dart`

---

[2026-04-24] - Eliminiación: Remoción de documentos obsoletos — (ver commit `2404ac7`)

---

## Features Completadas y Funcionando (No tocar sin justificación)

### Auth (100%)
- Sign in / Sign up con email + password.
- Google OAuth con flujo PKCE.
- Sign out y manejo de sesión.
- Guards de navegación (redirect a /auth si no hay sesión).
- Tests: `sign_in_with_email_usecase_test`, `sign_up_with_email_usecase_test`, `sign_in_with_google_usecase_test`, `sign_out_usecase_test`.

### Habits Core (90%)
- CRUD completo de hábitos (crear, editar, eliminar con confirmación).
- Tracking de progreso diario con contador +/-.
- Paginación (10 hábitos por página).
- Visualización semanal de progreso (WeeklyProgress widget).
- Offline-first: escritura en SQLite → sync asíncrono a Supabase.
- Banner de modo offline + indicador de estado de sync.
- Selección de icono (IconPicker).
- Selección de tipo (TypeHabitSelector).
- Estadísticas por hábito (StatisticsHabit widget).
- Tests: `create_habit_test`, `save_habit_progress_usecase_test`, `item_habit_model_test`, `habits_provider_test`.

### Infraestructura (100%)
- GoRouter con StatefulShellRoute (bottom nav con estado preservado).
- SyncService con cola FIFO y blocking de dependencias.
- ThemeProvider con persistencia en SharedPreferences.
- AppLogger centralizado.
- DependencyInjection singleton.
- NetworkInfo para detección de conectividad.

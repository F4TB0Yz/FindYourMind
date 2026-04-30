# ACTIVE_CONTEXT.md — Memoria de Trabajo

> **INSTRUCCIÓN PARA EL AGENTE**: Este archivo es tu estado mental del proyecto. Al inicio de cada sesión, léelo y verifica que su contenido coincide con el estado real del código. Si hay discrepancias, corrígelas. Al finalizar cualquier cambio significativo, actualiza este archivo antes de reportar al usuario.

_Última actualización: 2026-04-29 — Migración de hábitos a tracking unificado completada_

---

## Foco Actual

**Feature/Tarea**: Migración de hábitos a tracking unificado y cierre de cambios pendientes.

**Descripción**: Unificado el esquema de hábitos a `category` + `trackingType` + `targetValue` y `habit_logs` como fuente de progreso. Añadida iconografía `hugeicons` + emojis, actualizada la UI de hábitos y la sincronización para `log/value`. Incluida política de retry/backoff en `SyncService`.

**Estado**: ✅ Completo. Validación puntual sin errores en los archivos tocados por la migración.

---

## Estado del Proyecto por Feature

| Feature | Capa Domain | Capa Data | Capa Presentation | Tests |
|---|---|---|---|---|
| **Auth** | ✅ Completo | ✅ Completo | ✅ Completo | ✅ UseCases cubiertos |
| **Habits** | ✅ Completo | ✅ Completo | ✅ Completo | ✅ LocalDS + Provider + Sync |
| **Notes** | ❌ No implementado | ❌ No implementado | 🚧 Placeholder (SoonWidget) | ❌ Sin tests |
| **Tasks** | ❌ No implementado | ❌ No implementado | 🚧 Placeholder (SoonWidget) | ❌ Sin tests |
| **Profile** | ❌ No implementado | ❌ No implementado | 🚧 Placeholder (SoonWidget) | ❌ Sin tests |

---

## Bloqueos Activos (Blockers)

_Ninguno conocido al momento de inicialización._

---

## Decisiones Pendientes

- [x] ✅ Definir política de retry en `SyncService` (Max 5 reintentos).
- [x] ✅ Migrar queries de `sqflite` a `drift` puro — Completado 2026-04-24.
- [ ] Evaluar implementación de `home_widget`.
- [ ] Definir diseño de features Notes y Tasks.

---

## Próximos Pasos (Next Actions)

Ordenados por prioridad:

1. **Persistencia remota**: Aplicar SQL nuevo en Supabase real antes de usar sync en producción.
2. **UX detail/edit**: Afinar edición por tipo (`single` fija meta, `timed` quizá input de minutos más rico).
3. **Implementar feature Notes o Tasks**: Elegir una para próximo sprint.
4. **Mocking Supabase**: Investigar mejores formas de testear el RemoteDataSource sin acoplamiento a internals de postgrest.

---

## Contexto Técnico Activo

- **Branch actual**: `main`
- **Último commit**: `909cef0` — ui(habits): progreso, estadísticas y card expandible
- **Cambio en sesión** (sin commit aún):
  - Editado: `lib/core/database/app_database.dart` (schema v2 + `AppDatabase.forTesting`)
  - Editado: `lib/core/services/sync_service.dart` (retry policy, dead-letter methods, `log` sync)
  - Editado: `lib/features/habits/*` (migración de entidades, datasources, providers y UI)
  - Editado: `pubspec.yaml` / `pubspec.lock` (`hugeicons`, `shimmer`)
  - Creado: `test/core/services/sync_service_test.dart`
  - Creado: `test/features/habits/data/datasources/habits_local_datasource_test.dart`
  - Sesión previa: Undo de hábito single, rediseño total de hábitos con soporte `single/timed/counter`.

---

## Notas de Sesión

- **Sesión 2026-04-29 (3)**: Migración de hábitos a tracking unificado. `HabitEntity` usa `category`, `trackingType`, `targetValue` y `logs`; el sync y la persistencia ahora operan sobre `habit_logs` con `value`.

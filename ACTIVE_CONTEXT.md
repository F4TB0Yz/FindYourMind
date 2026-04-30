# ACTIVE_CONTEXT.md — Memoria de Trabajo

> **INSTRUCCIÓN PARA EL AGENTE**: Este archivo es tu estado mental del proyecto. Al inicio de cada sesión, léelo y verifica que su contenido coincide con el estado real del código. Si hay discrepancias, corrígelas. Al finalizar cualquier cambio significativo, actualiza este archivo antes de reportar al usuario.

_Última actualización: 2026-04-29 — Fase 1 (SQL v2) + Fase 2 (Tests) + Mocking Wrapper completados_

---

## Foco Actual

**Feature/Tarea**: Persistencia Remota + Test Infrastructure + Mocking Wrapper.

**Descripción**: 
- SQLs actualizados: schema v2 sin `synced`, RLS habilitado (fix: `user_id::uuid = auth.uid()`), migrations/rollback creados, function con user_id filter.
- Fixtures/mocks centralizados en `test/fixtures/`.
- Tests repository impl (27 tests) pasando.
- Tests remote datasource (17 tests) pasando con wrapper abstraction.
- ADR-008 documentado.
- `SupabaseClientWrapper` creado - abstracción para testing sin acoplamiento a postgREST.

**Estado**: ✅ Completo.

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

 1. **UX detail/edit**: Afinar edición por tipo (`single` fija meta, `timed` quizá input de minutos más rico).
 2. **Implementar feature Notes o Tasks**: Elegir una para próximo sprint.
 3. **Evaluar implementación de `home_widget`**.
 4. **Definir diseño de features Notes y Tasks**.

---

## Contexto Técnico Activo

 - **Branch actual**: `main`
 - **Cambio en sesión**:
   - SQL: `init.sql`, `tables/habits.sql`, `tables/habit_logs.sql`, `functions/get_habits_with_logs.sql`, `migrations/v1_to_v2_migration.sql`, `migrations/v2_rollback.sql`
   - Docs: `ARCHITECTURAL_DECISIONS.md` (ADR-008)
   - Fixtures: `test/fixtures/habit_fixtures.dart`, `test/fixtures/mocks.dart`
   - Tests: `habits_remote_datasource_test.dart` (rewrite con wrapper), `habit_repository_impl_test.dart` (new - 27 tests), `sync_service_test.dart` (expanded)
   - **NEW**: `lib/core/network/supabase_client_wrapper.dart` (abstracción para testing)

---

## Notas de Sesión

 - **Sesión 2026-04-29**: Fase 1 (SQL) + Fase 2 (Tests). Schema v2 sin synced, RLS, migrations. Repository tests (27) pasando, sync tests (14/17) con 3 failures menores en nuevos grupos (markPendingSync upsert, dependency chain).
 - **Sesión 2026-04-29b**: Abstracción `SupabaseClientWrapper` creada. Tests remote datasource (17/17) pasando. decoupling de postgREST.

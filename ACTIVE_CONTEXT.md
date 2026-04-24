# ACTIVE_CONTEXT.md — Memoria de Trabajo

> **INSTRUCCIÓN PARA EL AGENTE**: Este archivo es tu estado mental del proyecto. Al inicio de cada sesión, léelo y verifica que su contenido coincide con el estado real del código. Si hay discrepancias, corrígelas. Al finalizar cualquier cambio significativo, actualiza este archivo antes de reportar al usuario.

_Última actualización: 2026-04-24 — Migración sqflite → Drift completada_

---

## Foco Actual

**Feature/Tarea**: Migración sqflite → Drift (NativeDatabase, typed queries).

**Descripción**: Reemplazo completo de sqflite raw queries por Drift DSL tipado:
- Eliminadas dependencias: `sqflite`, `sqflite_common_ffi`, `drift_sqflite`
- Nueva: `AppDatabase` con 3 tablas tipadas (Habits, HabitProgress, PendingSync) → `app_database.g.dart` generado
- Reescritos: `HabitsLocalDatasourceImpl` (queries tipadas), `SyncService` (Drift DSL)
- Actualizado: DI usa `AppDatabase` directo (eliminado typedef shim `database_helper.dart`)
- Test: `SignOutUseCase` ahora mockea `AppDatabase`

**Estado**: ✅ Completo. `flutter analyze`: 0 errores. Commit: `50f396a`

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
- **Archivos modificados** (commit `50f396a`):
  - Nueva: `lib/core/database/app_database.dart` (Drift + NativeDatabase)
  - Reescritos: `habits_local_datasource.dart`, `sync_service.dart` (Drift DSL)
  - Eliminado: `lib/core/config/database_helper.dart` (typedef shim)
  - Actualizado: DI, auth tests, pubspec.yaml

---

## Notas de Sesión

_Usar esta sección para notas temporales de la sesión actual. Limpiar al finalizar._

- **Sesión 2026-04-24**: Migración sqflite → Drift completada. Aprendizaje: trabajé en worktree sin darlo cuenta. Próxima: verificar `pwd` y branch al inicio. Preferencia: editar directo en `main/`, no en worktrees.

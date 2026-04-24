# ACTIVE_CONTEXT.md — Memoria de Trabajo

> **INSTRUCCIÓN PARA EL AGENTE**: Este archivo es tu estado mental del proyecto. Al inicio de cada sesión, léelo y verifica que su contenido coincide con el estado real del código. Si hay discrepancias, corrígelas. Al finalizar cualquier cambio significativo, actualiza este archivo antes de reportar al usuario.

_Última actualización: 2026-04-24 — Inicialización del sistema de memoria_

---

## Foco Actual

**Feature/Tarea**: Inicialización del Sistema de Memoria Basado en Documentación (Context Engineering).

**Descripción**: Se creó la estructura jerárquica de archivos de contexto (`CLAUDE.md`, `AGENTS.md`, `PROJECT_CONTEXT.md`, `ARCHITECTURAL_DECISIONS.md`, `ACTIVE_CONTEXT.md`, `PROGRESS_LOG.md`) para permitir que agentes de IA carguen el estado del proyecto sin necesidad de analizar el código fuente completo.

**Estado**: Completo. Pendiente validación y primer uso real en sesión de desarrollo.

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
- [ ] Decidir si migrar queries de `sqflite` a `drift` puro (ADR-005 está parcialmente activo).
- [ ] Evaluar implementación de `home_widget` (dependencia instalada pero sin uso visible).
- [ ] Definir diseño de features Notes y Tasks (no hay spec).

---

## Próximos Pasos (Next Actions)

Ordenados por prioridad:

1. **Verificar sync service**: Revisar `lib/core/services/sync_service.dart` — confirmar que retry_count tiene lógica de backoff y límite definido.
2. **Completar migración a Drift**: Identificar queries directas de sqflite en `habits_local_datasource.dart` que no usan Drift todavía.
3. **Aumentar cobertura de tests**: DataSources local y remoto no tienen tests. Agregar tests para `HabitsLocalDatasourceImpl`.
4. **Implementar feature Notes o Tasks**: Elegir una para el próximo sprint. Seguir estructura de `habits/` como template.
5. **Profile screen**: Conectar con datos reales del usuario via `GetCurrentUserUseCase`.

---

## Contexto Técnico Activo

- **Branch actual**: `claude/serene-raman-c4291f`
- **Último commit significativo**: `14e8f01` — unificación de navegación global y rediseño del MainFab
- **Archivos con cambios recientes** (según git log):
  - Navegación global (`app_shell.dart`, bottom nav, `main_fab.dart`)
  - Layout refactor (`feature_layout.dart`)
  - Fix de lints en tests
  - Integración de auth real (eliminó constantes hardcodeadas)

---

## Notas de Sesión

_Usar esta sección para notas temporales de la sesión actual. Limpiar al finalizar._

- Sistema de memoria inicializado. Próxima sesión: leer este archivo y `AGENTS.md` primero.

# AGENTS.md — Sistema Operativo del Agente

## Identidad y Rol

Actúas como Ingeniero de Software Principal. Tu responsabilidad es mantener la integridad arquitectónica, minimizar deuda técnica y ejecutar cambios quirúrgicos. ERES el único responsable de mantener este sistema de memoria actualizado.

---
## ANTES DE NADA: 
- Activar skill caveman lite.
## graphify

This project has a graphify knowledge graph at graphify-out/.

Rules:
- Before answering architecture or codebase questions, read graphify-out/GRAPH_REPORT.md for god nodes and community structure
- If graphify-out/wiki/index.md exists, navigate it instead of reading raw files
- For cross-module "how does X relate to Y" questions, prefer `graphify query "<question>"`, `graphify path "<A>" "<B>"`, or `graphify explain "<concept>"` over grep — these traverse the graph's EXTRACTED + INFERRED edges instead of scanning files
- After modifying code files in this session, run `graphify update .` to keep the graph current (AST-only, no API cost)
---

## Stack Técnico Obligatorio

Solo puedes usar las siguientes tecnologías. **NUNCA** sugieras alternativas sin aprobación explícita:

- **Framework**: Flutter (≥3.41.7) + Dart (≥3.8.1)
- **Backend / Auth**: Supabase (PostgreSQL + Auth + Realtime). OAuth Google con flujo PKCE.
- **DB Local (Offline-first)**: SQLite via `drift` (esquema tipado).
- **Navegación**: `go_router` ^14.6.3. Stateful shell para bottom nav.
- **Error handling**: `dartz` Either<Failure, T> en domain y data. Cero excepciones en domain.
- **Logging**: Solo `AppLogger` (wrapper de `logger`). No usar `print()` ni `debugPrint()`.
---

## UI / UX
- Proyecto utiliza GoogleFonts por defecto.

## Reglas de Comportamiento del Agente

### 1. No programar sin contexto
- ANTES de escribir código o empezar a buscar como loco lo que no sabes: Haz preguntas al usuario hasta que entiendas el contexto completo o que es la solicitud exacta que quiere el usuario, para esto ejecuta el comando de preguntas.
- NO ASUMIR.

### 2. Validar antes de declarar hecho
- Después de un cambio: compilar, correr tests, o verificar que funciona.
- Nunca decir "listo" sin evidencia de que funciona.

### 3. Soluciones simples
- Implementar lo mínimo que resuelve el problema. Nada más.
- No agregar abstracciones, helpers, tipos, validaciones, ni features no solicitados.
- 3 líneas repetidas > 1 abstracción prematura.

### 4. Paralelizar tool calls
- Si se necesitan leer 3 archivos independientes, leer los 3 en un solo mensaje.
- Menos roundtrips = menos tokens de contexto acumulado.

### 5. No duplicar código en la respuesta
- Si ya se editó un archivo, no copiar el resultado en la respuesta. El usuario lo ve en el diff.
- Si se creó un archivo, no mostrarlo entero en texto también.

### 6. No usar Agent cuando Grep/Read basta
- Los agentes duplican todo el contexto en un subproceso. Solo usar para búsquedas amplias o tareas complejas multi-paso.
- Para buscar una función o archivo específico, usar grep o glob directo.

---

## Reglas de Ejecución Técnica

### R1: Nunca reescribir, siempre diff
Usar `Edit` para archivos existentes. `Write` solo para archivos nuevos. Commits atómicos: un cambio semántico = un commit.

### R2: Verificar antes de asumir
La documentación puede estar desactualizada. El código es la fuente de verdad.

### R3: No inventar APIs
Si no confirmas la existencia de un método/clase con `grep` o `Read`, no lo uses.

### R4: Separación estricta de capas
- **Domain**: cero imports de `data/` o `presentation/`. Solo Dart puro + dartz.
- **Data**: implementa interfaces de `domain/`. Maneja excepciones → Failures.
- **Presentation**: solo consume UseCases o Repositories via inyección. Nunca toca Supabase directamente.

### R5: Propagación de errores con dartz
```dart
// ✅ En repositorio
try {
  return Right(await remoteDataSource.getHabits());
} on ServerException catch (e) {
  return Left(ServerFailure(e.message));
}
// ❌ Prohibido en domain
throw SomeException();
```

---

## Protocolo de Auto-Mantenimiento (Memory Flush)

**El agente actualiza los archivos de memoria. El usuario no copia y pega resúmenes.**

### `ACTIVE_CONTEXT.md` — actualizar cuando:
- Inicio de sesión (verificar y corregir si está desactualizado).
- Cambia el foco de trabajo (nueva feature, nuevo bug, nueva decisión de diseño).
- Se resuelve un blocker.
- Fin de sesión o sprint.

### `PROGRESS_LOG.md` — actualizar cuando:
- Merge de feature completa a `main`.
- Bug fix en producción.
- Refactor que cambia contratos públicos.
- Formato: `[YYYY-MM-DD] - <Tipo>: <Descripción> - <Archivos principales>`.

### `ARCHITECTURAL_DECISIONS.md` — actualizar cuando:
- Nueva decisión técnica que afecte convenciones globales.
- Cambio de decisión previa → marcar la anterior como `[SUPERSEDED por ADR-XX]`.

### `PROJECT_CONTEXT.md` — actualizar cuando:
- Nueva dependencia en `pubspec.yaml`.
- Nueva tabla en Supabase o cambio en las tablas.
- Cambio en objetivos del producto.
---

## Checklist Pre-Acción

- [ ] ¿Leí `ACTIVE_CONTEXT.md` esta sesión?
- [ ] ¿Verifiqué que el archivo a editar existe y contiene lo que asumo?
- [ ] ¿El cambio respeta la separación de capas?
- [ ] ¿Necesito actualizar algún archivo de memoria?

## Checklist Post-Acción (OBLIGATORIO — no reportar al usuario antes de completar)

- [ ] **Actualizar `ACTIVE_CONTEXT.md`**: foco actual, archivos modificados, notas de sesión.
- [ ] ¿El analyze/tests pasan sin errores?
- [ ] Si hubo decisión técnica nueva → actualizar `ARCHITECTURAL_DECISIONS.md`.
- [ ] Si se completó una feature → actualizar `PROGRESS_LOG.md`.

---

## Restricciones Absolutas

- **No** agregar dependencias a `pubspec.yaml` sin discutirlo.
- **No** modificar esquema Supabase sin SQL documentado en `ARCHITECTURAL_DECISIONS.md`.
- **No** cambiar GoRouter sin evaluar impacto en guards de autenticación.
- **No** usar `setState` fuera de Widgets stateful.
- **No** `Provider.of(context, listen: true)` fuera de métodos `build`.
- **No** acceder a `supabase.client` desde Presentation layer.
- **No** usar `dynamic` salvo en deserialización de JSON con cast inmediato.

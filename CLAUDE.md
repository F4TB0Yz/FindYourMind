# CLAUDE.md — Enrutador de Contexto

> **DIRECTIVA OBLIGATORIA**: Este archivo es únicamente un enrutador. No contiene reglas operativas.
>
> **ANTES de ejecutar cualquier acción, leer o escribir cualquier archivo, o responder al usuario**, DEBES leer los siguientes archivos en este orden exacto:
>
> 1. `AGENTS.md` — Reglas operativas, restricciones de ejecución y protocolo del agente.
> 2. `ACTIVE_CONTEXT.md` — Estado actual del proyecto, bloqueos y próximos pasos.
>
> No saludes. No preguntes qué hacer. Lee ambos archivos, asimila su contenido y confirma con una línea: `[Contexto cargado: <fecha de ACTIVE_CONTEXT.md>]`. Luego procede.

## Archivos del Sistema de Memoria

| Archivo | Propósito | Frecuencia de actualización |
|---|---|---|
| `AGENTS.md` | System prompt del agente, reglas de ejecución | Raramente (solo cambios de contrato) |
| `PROJECT_CONTEXT.md` | Stack, visión, métricas de éxito | Por release o cambio mayor de stack |
| `ARCHITECTURAL_DECISIONS.md` | Contratos técnicos, convenciones, ADRs | Por decisión arquitectónica nueva |
| `ACTIVE_CONTEXT.md` | Estado actual, bloqueos, próximos pasos | **Al inicio y fin de cada sesión** |
| `PROGRESS_LOG.md` | Historial inmutable de cambios fusionados | Tras cada merge/deploy significativo |

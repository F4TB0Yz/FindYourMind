# AGENTS.MD

# Reglas para el AGENTE
- 

# FindYourMind - Agent Core Directives
Eres un desarrollador Flutter Senior y Arquitecto de Software trabajando en el proyecto FindYourMind. Tu objetivo es escribir código limpio, modular y mantenible, siguiendo estrictamente estas directivas.

## 1. Stack Técnico Obligatorio
Solo puedes utilizar las siguientes tecnologías. NUNCA sugieras ni implementes alternativas sin mi aprobación explícita:

- **Framework:** Flutter (3.41.7+).
- **Lenguaje:** Dart (3.11.5+).
- **Backend / Auth:** Supabase (Auth Real + PostgreSQL + Realtime). OAuth con Google (PKCE).
- **Base de Datos Local (Offline-first):** SQLite a través de `sqflite` y `Drift`.
- **Gestión de Estado:** `Provider` (PROHIBIDO usar Riverpod, Bloc o GetX).
- **UI / Diseño:** Material Design 3. El sistema de diseño se basa en la clase `AppColors`. Usa íconos `Lucide`.
- **Logging:** Uso exclusivo de `AppLogger` (logger centralizado).

## 2. Arquitectura (Clean Architecture)
El código debe estar separado en capas estrictas. NUNCA mezcles la lógica de negocio con la UI.

- **Domain:** Entidades, Modelos y Contratos (Interfaces) de los Repositorios. Cero dependencias externas.
- **Data:** Implementación de Repositorios, Data Sources (Local DB con Drift, Remote DB con Supabase).
- **Presentation:** Widgets, Screens y State Management (Providers).
- Cada feature (`auth`, `habits`, `notes`, `tasks`, `profile`) debe tener su propio módulo aislado siguiendo esta separación.

## 3. Reglas de Codificación y Estilo
- **Seguridad de Tipos:** Sé estricto con los tipos. Evita el uso de `dynamic`. Utiliza null-safety correctamente.
- **Composición sobre Herencia:** Prefiere componentes pequeños y reutilizables.
- **Validación Completa:** Si arreglas un bug, debes probar tu cambio empíricamente. NUNCA uses métodos engañosos o parches rápidos ("hacks").
- **UI Responsiva:** Construye siempre pensando en diferentes tamaños de pantalla, aunque el foco sea mobile.

## 4. AUTO-MANTENIMIENTO DE MEMORIA (DIRECTIVA CRÍTICA)
Eres un agente autónomo y responsable de mantener tu propio contexto. Después de completar cualquier modificación funcional de código,
resolver un bug o avanzar en una tarea, **TIENES LA OBLIGACIÓN** de realizar las siguientes acciones ANTES de pedir mi aprobación final:

1. **Actualizar `TASK.md`:** Abre y edita el archivo `TASK.md` para marcar los pasos completados, documentar el estado actual en el que dejas
el proyecto y definir claramente los siguientes pasos.

2. **Reflexión (`.agent/decisions/`):** Si tomaste una decisión arquitectónica importante (ej. cambiar un modelo de datos) o resolviste un bug
complejo (ej. un problema con PKCE en OAuth), DEBES crear un archivo Markdown corto explicándolo dentro del directorio `.agent/decisions/`
(crea la carpeta si no existe).

3. **No termines sin documentar:** Nunca me digas que has terminado una tarea si no has actualizado primero estos archivos.

## 5. Protocolo de Ejecución
- Cuando iniciemos sesión, lo primero que debes hacer es leer este archivo (`AGENT.md`) y el estado actual en `TASK.md`.
- No pidas permiso para actualizar `TASK.md`, hazlo directamente usando tus herramientas de edición de archivos.
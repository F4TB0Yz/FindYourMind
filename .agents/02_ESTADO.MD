# 📝 ESTADO DEL SPRINT Y MEMORIA DE TRABAJO (MUTABLE)

## 📊 CONTEXTO RESUMIDO
- Se implementó con éxito el sistema Offline-First con sincronización automática.
- Rediseño de Dashboard bajo la **Ley de Fitts** (FAB centrado y accesible).
- Sistema de **Visualización Avanzada de Hábitos** con Glassmorfismo, efectos de Dopamina (Glow).
- **Feedback Instantáneo (Dopamine Engineering)**: Micro-explosión de partículas, contracción de tarjetas y barra de progreso global animada.
- **Arquitectura Limpia**: Refactorización del flujo de creación de hábitos para centralizar orquestación en el dominio.
- **UX Onboarding**: Implementación de Empty States y persistencia del FAB para mejorar el flujo de creación.

## 🎯 ÚLTIMA ACCIÓN REALIZADA
- **Refactorización de `SyncService`: FIFO estricto + Bloqueo en Cascada (Dependency Awareness)**:
  1. **`syncPendingChanges` unificado**: Eliminada la separación en `habitItems`/`progressItems` y el método auxiliar `_syncItems`. La cola se procesa como una sola lista ordenada por `created_at ASC`.
  2. **Bloqueo en Cascada**: Se introdujo `Set<String> failedHabitIds`. En cada iteración se resuelve el `associatedHabitId` (para `habit`, es `entity_id`; para `progress`, se extrae del JSON con `_resolveHabitId`). Si el hábito padre falló, el progreso dependiente se incrementa en `retry_count` y se salta con `continue` sin hacer llamadas a red, previniendo violaciones de FK en Supabase.
  3. **Helper `_resolveHabitId` extraído**: Encapsula la extracción del `habit_id` desde el JSON del campo `data`, permitiendo declaración `final` limpia en el bucle principal.
  4. **`deleteHabitPendingSync` expandido en `HabitsLocalDatasourceImpl`**: El DELETE ahora usa una condición compuesta: elimina la tarea del hábito (`entity_type='habit' AND entity_id=?`) Y todas las tareas de sus progresos (`entity_type='progress' AND data LIKE '%"habit_id":"<id>"%'`). Previene tareas huérfanas sin requerir migración de BD.

## 🚀 TAREAS PENDIENTES (BACKLOG INMEDIATO)
1. Pulir la pantalla de Perfil (`ProfileScreen`) con indicadores de racha (streaks) y logros usando los nuevos estilos de Glassmorfismo.
2. Añadir indicadores visuales (badges/snackbars) para el estado de sincronización pendiente en la Home.
3. Implementar las acciones rápidas (Quick Actions) adicionales en el FAB expandible (ej. check-in rápido).

## 👉 SIGUIENTE PASO LÓGICO
Continuar con el **Rediseño de la Pantalla de Perfil**, integrando la visualización de **Racha (Streak)** y **Total Completado** (Logros) con el nuevo lenguaje visual de Glassmorfismo.
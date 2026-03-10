---
name: flutter_performance
description: Aplica estrictamente las mejores prácticas de rendimiento de Flutter. Usa esta skill cada vez que generes, refactorices o revises código de UI en Flutter para asegurar 60/120fps, métodos build 100% puros y un uso agresivo de const.
---

# Flutter Performance

El método `build` es terreno sagrado. Tu único trabajo ahí es devolver un árbol de widgets, NO pensar, NO calcular, NO pedir datos. Si la UI hace esperar al usuario porque estás procesando algo en el hilo principal, has fallado.

## Reglas Inquebrantables (Hard No)

- **Cero lógica pesada en `build()`:** Prohibido instanciar clases pesadas, filtrar listas largas o hacer parseos de JSON/fechas. Todo eso va en el `initState`, en el controlador (Bloc/Provider/Riverpod) o en un Isolate.
- **Cero asincronía huérfana en la UI:** Nada de llamar a APIs, bases de datos o `SharedPreferences` directo en el `build`. Si necesitas un `FutureBuilder`, el `Future` debe estar instanciado fuera del `build` (en el `initState` o en el controlador) para que no se dispare de nuevo con cada rebuild.
- **Cero `setState` destructivos:** Prohibido llamar a `setState` en la raíz de una vista completa solo para cambiar el estado de un mísero Checkbox. Extrae ese componente a su propio `StatefulWidget` o usa un `ValueNotifier` / `Builder`. Aislar el estado es aislar el impacto del render.
- **Cero listas perezosas sin `builder`:** Prohibido usar `ListView()` o `GridView()` estándar si hay más de 15 elementos. Usa SIEMPRE `ListView.builder` o Slivers. Renderizar lo que no se ve en pantalla es un crimen de memoria.
- **Cero métodos constructores de Widgets:** Prohibido crear funciones gigantes tipo `Widget _buildMiBoton() { ... }`. Eso engaña al árbol de widgets de Flutter. Extrae esos fragmentos en **clases reales** que extiendan `StatelessWidget` (ej. `class MiBoton extends StatelessWidget`).
- **Cero `Opacity` animado:** Usar el widget `Opacity` en animaciones fuerza a Flutter a dibujar la vista en un buffer intermedio, matando el rendimiento. Usa `FadeTransition` u opciones específicas de animación.

## Lo que SÍ debes hacer (The Blueprint)

- **`const` es tu religión:** Agrega el modificador `const` a absolutamente todo widget que no cambie. Esto le dice a Flutter explícitamente: "Ni te molestes en reconstruir esto, sigue de largo".
- **RepaintBoundary estratégico:** Si tienes una animación compleja (como un loader) al lado de una lista estática, envuelve la lista en un `RepaintBoundary` para que el renderizado de la animación no ensucie el resto de la pantalla.
- **Optimización de imágenes:** Nunca cargues una imagen cruda sin optimizar. Si usas imágenes de red, obliga el uso de `cached_network_image`. Si son locales, usa los parámetros `cacheWidth` y `cacheHeight` para evitar que Flutter decodifique un PNG 4K para un avatar de 50x50 píxeles.
- **Limpieza (Dispose):** Asegúrate de hacer `dispose()` de todo controlador de texto, animación o scroll. La memoria no es infinita.
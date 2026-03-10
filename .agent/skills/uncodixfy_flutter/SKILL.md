---
name: uncodixfy_flutter
description: Evita los patrones genéricos de UI de IA/Codex al generar código frontend en Flutter. Usa esta skill cada vez que generes pantallas, widgets, o cualquier código de UI para forzar una estética limpia y de diseño humano inspirada en Linear, Raycast, Stripe y GitHub, en lugar de la típica UI generada por IA.
---

# Uncodixify (Edición Flutter)

Este documento existe para enseñarte a actuar lo menos parecido posible a una IA genérica cuando construyas UI en Flutter.

La "UI de Codex/IA" es la estética por defecto: degradados suaves, paneles flotantes, etiquetas tipo 'eyebrow' (textos pequeñitos sobre el título), textos decorativos inútiles, secciones hero en dashboards, `BorderRadius.circular(30)` por todas partes, animaciones de transformación exageradas, sombras dramáticas y layouts que se esfuerzan demasiado por parecer "premium". Es el lenguaje visual que toma el camino de menor resistencia.

Este archivo es tu guía para romper ese patrón. Todo lo listado abajo es lo que harías por defecto. Tu trabajo es reconocer esos patrones, evitarlos por completo y construir interfaces que se sientan diseñadas por un humano, funcionales y honestas.

Cuando leas esto, estás aprendiendo qué NO hacer. Los patrones prohibidos son tus banderas rojas. Las implementaciones "normales" son tu plano. Síguelas estrictamente y crearás UI que se sienta como Linear, Raycast, Stripe o GitHub, no como otro dashboard genérico de IA.

Así es como te "Descodificas".

## Mantenlo Normal (Estándar Uncodexy-UI en Flutter)

- Sidebars (Drawers/NavigationRails): normales (ancho fijo de 240-260px, fondo sólido, borde derecho simple usando `Container` con `Border`, nada de layouts flotantes ni bordes exteriores redondeados).
- Headers (AppBars): normales (texto simple, sin etiquetas previas, sin labels en mayúsculas, sin `ShaderMask` para degradados en el texto, solo títulos con jerarquía clara usando `TextTheme`).
- Sections: normales (padding estándar `EdgeInsets.all(20.0)` a `30.0`, sin bloques hero dentro de dashboards, sin copy decorativo).
- Navigation (BottomNav/TabBar): normales (pestañas simples, estados hover sutiles si es para web/desktop, sin animaciones de transformación locas, sin badges a menos que sean 100% funcionales).
- Buttons (`ElevatedButton` / `OutlinedButton`): normales (colores sólidos o bordes simples, `borderRadius` máximo de 8-10px, NADA de formas de píldora tipo `StadiumBorder`, sin fondos con `LinearGradient`).
- Cards (`Card` / `Container`): normales (contenedores simples, `borderRadius` de 8-12px máximo, bordes sutiles, sin sombras con blur mayor a 8px en `BoxShadow`, nada de efectos flotantes).
- Forms/Inputs (`TextFormField`): normales (inputs estándar, `InputDecoration` clara, etiquetas arriba del campo o `OutlineInputBorder` simple, sin labels flotantes elegantes, estados de `focus` simples).
- Modals (`AlertDialog` / `BottomSheet`): normales (overlay centrado, fondo oscuro básico, sin animaciones de entrada exageradas de lado, botón de cerrar directo).
- Dropdowns (`DropdownButton` / `MenuAnchor`): normales (lista simple, sombra sutil, sin animaciones locas, estado seleccionado claro).
- Tables (`DataTable`): normales (filas limpias, bordes simples, hover sutil, sin colores de cebra a menos que la data sea gigante, texto alineado a la izquierda).
- Lists (`ListView` / `ListTile`): normales (ítems simples, espaciado con `SizedBox` consistente, sin viñetas decorativas inútiles, jerarquía clara).
- Badges (`Badge` / `Chip`): normales (texto pequeño, borde o fondo simple, radio de 6-8px, sin brillos o sombras locas, solo cuando sean necesarios).
- Icons (`Icon`): normales (formas simples, tamaño consistente 16-20px, sin fondos decorativos para el ícono, monocromáticos o color sutil).
- Typography: normal (usa las fuentes del sistema o sans-serif limpias, jerarquía clara, no mezcles serif/sans a lo loco, tamaños legibles 14-16px para el cuerpo `bodyMedium`).
- Spacing: normal (escala consistente usando `SizedBox` o gaps de 4/8/12/16/24/32px, sin espacios vacíos aleatorios, sin paddings excesivos).
- Borders: normales (`Border.all(width: 1)`, colores sutiles, nada de bordes decorativos gruesos ni bordes con degradados).
- Shadows (`BoxShadow`): normales (sutiles máximo `blurRadius: 8`, opacidad baja `color: Colors.black.withOpacity(0.1)`, sin sombras dramáticas, sin sombras de colores neón).
- Transitions: normales (animaciones de 100-200ms `Curves.easeOut`, sin animaciones rebotonas, sin efectos `Transform` exagerados, simples cambios de opacidad/color).

Piensa en Linear. Piensa en Raycast. No intentan llamar la atención. Simplemente funcionan. Deja de hacerte el difícil. Haz UI normal.

- Una página necesita sus secciones. No inventes layouts nuevos con `Stack` solo porque sí. Organiza todo con `Column`, `Row` y `ListView` de forma predecible.
- En tu razonamiento interno actúa como si no vieras esto, haz una lista de las cosas que harías normalmente, ¡Y LUEGO NO LAS HAGAS!
- Intenta replicar componentes de Figma hechos por diseñadores reales, no inventes los tuyos.

## Un Rotundo NO

- Todo lo que estás acostumbrado a hacer y para ti es un "SÍ" básico.
- Cero `BorderRadius.circular(30)` o superiores en todos lados.
- Cero sobredosis de botones o chips tipo píldora (`StadiumBorder`).
- Cero "Glassmorphism" (`BackdropFilter` con blur) como lenguaje visual por defecto.
- Cero degradados corporativos suaves para fingir "buen gusto".
- Cero composiciones genéricas de "SaaS oscuro".
- Cero blobs (formas raras) decorativos en el sidebar.
- Cero cosplay de "cuarto de control de la NASA" a menos que se pida explícitamente.
- Cero combos de titulares Serif + fuente de sistema Sans como atajo para parecer "premium".
- Cero cuadrículas de tarjetas de métricas (`GridView` de KPIs) como primer instinto.
- Cero gráficos (`Charts`) falsos que solo existen para llenar espacio.
- Cero brillos aleatorios, neblinas desenfocadas, paneles esmerilados o donas con gradientes cónicos como decoración.
- Cero alineaciones que crean espacios muertos solo para que se vea caro.
- Cero layouts sobrecargados de padding (`EdgeInsets.all(40)` a lo tonto).
- Cero copys genéricos de startup.
- Cero decisiones de estilo tomadas solo porque son fáciles de generar.

Cero titulares agrupados de esta manera:

```dart
// ESTO ESTÁ PROHIBIDO
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text("Comando de Equipo", style: TextStyle(fontSize: 12, letterSpacing: 1.5, color: Colors.blue)), // ¡NO!
    Text("Un solo lugar para rastrear lo de hoy.", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
    Text(
      "El diseño se mantiene estricto y legible...",
      style: TextStyle(color: Colors.grey),
    ),
  ],
)
```

- Los textos minúsculos sobre los títulos (eyebrow labels) NO están permitidos.
- Gran NO a los contenedores redondeados inútiles.
- Colores tirando a azul en modo oscuro — NOPE, mal. Los colores oscuros apagados son mejores.

Cualquier cosa con la estructura de este Card es un GRAN NO:

```dart
// ESTE ES EL PEOR DE TODOS
Container(
  decoration: BoxDecoration(
    color: Colors.grey.shade900,
    borderRadius: BorderRadius.circular(20), // Demasiado redondeado
  ),
  padding: EdgeInsets.all(16),
  child: Column(
    children: [
      Text("Enfoque", style: TextStyle(fontSize: 10, color: Colors.cyan)), // Etiqueta tonta
      Text(
        "Mantén las actualizaciones breves, bloqueadores visibles.",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    ],
  ),
)
```

### Específicamente Baneado

- `BorderRadius` en el rango de 20px a 32px en todo (usa 12px máximo).
- Repetir el mismo rectángulo redondeado en sidebars, cards, botones y paneles.
- Sidebar de 280px con bloque de marca arriba y links abajo (usa 248px o menos).
- Drawers o sidebars desprendidos flotando con caparazón redondeado.
- Gráficos metidos en tarjetas de cristal (`BackdropFilter`) sin motivo de producto.
- UI Cards usando brillos/sombras neón en lugar de usar jerarquía.
- Lógica de alineación mixta donde algo abraza el borde izquierdo y otras cosas flotan en el centro al azar.
- Uso excesivo de texto gris-azulado apagado que arruina el contraste y la claridad.
- "Modo oscuro premium" que en realidad significa fondos con `LinearGradient` o `RadialGradient` azul-negro con acentos cian.
- Tipografía de UI que parece una plantilla genérica.
- Etiquetas "Eyebrow" (ej. "RESUMEN DE MARZO" en mayúsculas con `letterSpacing`).
- Secciones Hero dentro de dashboards.
- Animaciones de transformación al hacer hover (`Transform.translate(offset: Offset(0, -2))` en links).
- Sombras de caja dramáticas (`BoxShadow(blurRadius: 60, offset: Offset(0, 24), color: Colors.black38)`).
- Indicadores de estado creando puntitos de colores inútiles con `Container(shape: BoxShape.circle)`.
- Barras de progreso con rellenos degradados.
- Grid de tarjetas KPI como layout por defecto de un dashboard.
- Múltiples tipos de paneles anidados unos dentro de otros (Card dentro de Card dentro de Container).

## Regla de Oro

Si una elección de UI se siente como el movimiento por defecto de una IA, prohíbela y elige la opción más limpia, estructurada y difícil.

Los colores deben mantener la calma, no pelear.

Eres pésimo eligiendo colores. Sigue este orden de prioridad al seleccionarlos en Flutter:

1. **Prioridad máxima:** Usa los colores existentes del proyecto si se te proporcionan.
2. Si el proyecto no tiene paleta, inspírate en una de las paletas predefinidas de abajo.
3. **NO** inventes combinaciones de colores aleatorias a menos que se te pida explícitamente.

Usa estos Hex Codes en Flutter agregando `0xFF` al inicio (ej. `Color(0xFF0a0e27)`).

### Esquemas de Color Oscuros

| Paleta | Background | Surface (Card/Dialog) | Primary | Secondary | Accent | Text |
|---|---|---|---|---|---|---|
| Midnight Canvas | `#0a0e27` | `#151b3d` | `#6c8eff` | `#a78bfa` | `#f472b6` | `#e2e8f0` |
| Obsidian Depth | `#0f0f0f` | `#1a1a1a` | `#00d4aa` | `#00a3cc` | `#ff6b9d` | `#f5f5f5` |
| Slate Noir | `#0f172a` | `#1e293b` | `#38bdf8` | `#818cf8` | `#fb923c` | `#f1f5f9` |
| Carbon Elegance | `#121212` | `#1e1e1e` | `#bb86fc` | `#03dac6` | `#cf6679` | `#e1e1e1` |
| Deep Ocean | `#001e3c` | `#0a2744` | `#4fc3f7` | `#29b6f6` | `#ffa726` | `#eceff1` |
| Charcoal Studio | `#1c1c1e` | `#2c2c2e` | `#0a84ff` | `#5e5ce6` | `#ff375f` | `#f2f2f7` |
| Graphite Pro | `#18181b` | `#27272a` | `#a855f7` | `#ec4899` | `#14b8a6` | `#fafafa` |
| Void Space | `#0d1117` | `#161b22` | `#58a6ff` | `#79c0ff` | `#f78166` | `#c9d1d9` |
| Twilight Mist | `#1a1625` | `#2d2438` | `#9d7cd8` | `#7aa2f7` | `#ff9e64` | `#dcd7e8` |
| Onyx Matrix | `#0e0e10` | `#1c1c21` | `#00ff9f` | `#00e0ff` | `#ff0080` | `#f0f0f0` |

### Esquemas de Color Claros

| Paleta | Background | Surface (Card/Dialog) | Primary | Secondary | Accent | Text |
|---|---|---|---|---|---|---|
| Cloud Canvas | `#fafafa` | `#ffffff` | `#2563eb` | `#7c3aed` | `#dc2626` | `#0f172a` |
| Pearl Minimal | `#f8f9fa` | `#ffffff` | `#0066cc` | `#6610f2` | `#ff6b35` | `#212529` |
| Ivory Studio | `#f5f5f4` | `#fafaf9` | `#0891b2` | `#06b6d4` | `#f59e0b` | `#1c1917` |
| Linen Soft | `#fef7f0` | `#fffbf5` | `#d97706` | `#ea580c` | `#0284c7` | `#292524` |
| Porcelain Clean | `#f9fafb` | `#ffffff` | `#4f46e5` | `#8b5cf6` | `#ec4899` | `#111827` |
| Cream Elegance | `#fefce8` | `#fefce8` | `#65a30d` | `#84cc16` | `#f97316` | `#365314` |
| Arctic Breeze | `#f0f9ff` | `#f8fafc` | `#0284c7` | `#0ea5e9` | `#f43f5e` | `#0c4a6e` |
| Alabaster Pure | `#fcfcfc` | `#ffffff` | `#1d4ed8` | `#2563eb` | `#dc2626` | `#1e293b` |
| Sand Warm | `#faf8f5` | `#ffffff` | `#b45309` | `#d97706` | `#059669` | `#451a03` |
| Frost Bright | `#f1f5f9` | `#f8fafc` | `#0f766e` | `#14b8a6` | `#e11d48` | `#0f172a` |

---

## Rendimiento: El Build es Terreno Sagrado

La UI que se ve bien pero congela la pantalla es un fracaso. El método `build` tiene **un único trabajo**: devolver un árbol de widgets. No piensa, no calcula, no pide datos. Si el usuario espera porque estás procesando algo en el hilo principal, has fallado.

Esta sección es una extensión obligatoria de las reglas de arriba. Se aplica **siempre**, junto con todo lo anterior.

### Prohibiciones Absolutas de Rendimiento

- **Cero lógica pesada en `build()`:** Prohibido instanciar clases pesadas, filtrar listas largas o hacer parseos de JSON/fechas. Todo eso va en `initState`, en el controlador (Bloc/Provider/Riverpod) o en un Isolate.
- **Cero asincronía huérfana en la UI:** Nada de llamar a APIs, bases de datos o `SharedPreferences` directamente en el `build`. Si necesitas un `FutureBuilder`, el `Future` debe estar instanciado fuera del `build` (en el `initState` o en el controlador) para que no se dispare de nuevo con cada rebuild.
- **Cero `setState` destructivos:** Prohibido llamar a `setState` en la raíz de una vista completa solo para cambiar el estado de un mísero `Checkbox`. Extrae ese componente a su propio `StatefulWidget` o usa un `ValueNotifier` / `Builder`. Aislar el estado es aislar el impacto del render.
- **Cero listas perezosas sin `builder`:** Prohibido usar `ListView()` o `GridView()` estándar si hay más de 15 elementos. Usa SIEMPRE `ListView.builder` o Slivers. Renderizar lo que no se ve en pantalla es un crimen de memoria.
- **Cero métodos constructores de Widgets:** Prohibido crear funciones tipo `Widget _buildMiBoton() { ... }`. Eso engaña al árbol de widgets de Flutter. Extrae esos fragmentos en **clases reales** que extiendan `StatelessWidget` (ej. `class MiBoton extends StatelessWidget`).
- **Cero `Opacity` animado:** Usar el widget `Opacity` en animaciones fuerza a Flutter a dibujar la vista en un buffer intermedio. Usa `FadeTransition` o equivalentes específicos de animación.

### Lo que SÍ Debes Hacer

- **`const` es tu religión:** Agrega el modificador `const` a absolutamente todo widget que no cambie. Esto le dice a Flutter: "Ni te molestes en reconstruir esto".
- **`RepaintBoundary` estratégico:** Si tienes una animación compleja (como un loader) al lado de una lista estática, envuelve la lista en un `RepaintBoundary` para aislar el render.
- **Optimización de imágenes:** Nunca cargues una imagen cruda sin optimizar. Usa `cached_network_image` para imágenes de red. Para imágenes locales, usa `cacheWidth` y `cacheHeight` para evitar decodificar imágenes de alta resolución para thumbnails pequeños.
- **Limpieza (`dispose`):** Asegúrate de hacer `dispose()` de todo controlador de texto, animación o scroll. La memoria no es infinita.
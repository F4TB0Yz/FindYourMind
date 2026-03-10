---
name: skills_index
description: Índice principal de skills disponibles para este proyecto. Define las reglas globales de cuándo activar cada skill.
---

# Skills del Proyecto — Reglas de Activación

Este archivo define cuándo y cómo debes usar cada skill disponible en este proyecto.
Léelo como un conjunto de **reglas obligatorias**, no como sugerencias.

---

## 🎨 UI — `uncodixfy_flutter`

**Ubicación:** `.agent/skills/UI/SKILL.md`

### Cuándo activarla (OBLIGATORIO)

Debes leer y aplicar la skill `uncodixfy_flutter` en **cualquiera** de estos casos:

- Vas a crear una pantalla nueva (`Screen`, `Page`, `View`).
- Vas a crear o modificar un widget de UI (`Widget`, `Component`, `Card`, `Button`, `Input`, etc.).
- Vas a ajustar estilos, colores, tipografía, espaciado o animaciones.
- El usuario menciona palabras como "diseño", "UI", "pantalla", "widget", "tema", "color" o "estilo".
- Vas a refactorizar o revisar código que toca la capa de `presentation`.

### Cómo activarla

1. Usa el tool `view_file` para leer `.agent/skills/UI/SKILL.md` **antes** de escribir cualquier línea de código de UI.
2. Aplica todas las reglas del archivo: patrones prohibidos, componentes normales y paletas de color.
3. No generes ni un solo widget sin haber leído el archivo primero en esa sesión.

> **Regla de oro:** Si tocas la UI, lees el archivo. Sin excepciones.

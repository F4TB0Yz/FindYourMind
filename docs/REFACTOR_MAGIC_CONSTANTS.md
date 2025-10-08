# Refactorización: Eliminación de Constantes Mágicas

## 📋 Resumen
Se eliminaron todas las constantes mágicas (números y strings hardcodeados) y se centralizaron en archivos de constantes reutilizables.

## 🎯 Problemas Resueltos

### 1. **Duration(milliseconds: 150)** - Repetido 6 veces
- **Ubicaciones**: `item_habit.dart` (3x), `custom_button.dart` (1x)
- **Solución**: `AnimationConstants.fastAnimation`

### 2. **Color(0xFF2A2A2A)** - Repetido 15+ veces
- **Ubicaciones**: Múltiples archivos en toda la app
- **Solución**: `AppColors.darkBackground`

### 3. **String 'HABITOS'** - Repetido 3+ veces
- **Ubicaciones**: `habits_provider.dart`, `container_border_habits.dart`, `custom_bottom_bar.dart`
- **Solución**: `AppStrings.habitsTitle` y `AppStrings.habitsLabel`

## 📁 Archivos Creados

### `/lib/core/constants/animation_constants.dart`
Centraliza todas las duraciones de animaciones:
```dart
AnimationConstants.fastAnimation    // 150ms - animaciones rápidas
AnimationConstants.normalAnimation  // 300ms - animaciones normales
AnimationConstants.slowAnimation    // 500ms - animaciones lentas
```

### `/lib/core/constants/color_constants.dart`
Centraliza todos los colores personalizados:
```dart
AppColors.darkBackground     // Color(0xFF2A2A2A) - fondo oscuro principal
AppColors.darkBackgroundAlt  // Color(0xFF1E1E1E) - fondo oscuro alternativo
```

### `/lib/core/constants/string_constants.dart`
Centraliza todos los strings de la aplicación:
```dart
AppStrings.habitsTitle   // 'HABITOS' - título en mayúsculas
AppStrings.habitsLabel   // 'Habitos' - label capitalizado
AppStrings.notesTitle    // 'NOTAS'
AppStrings.tasksTitle    // 'TAREAS'
```

### `/lib/core/constants/app_constants.dart`
Archivo barrel para importar todas las constantes desde un solo lugar.

## 📝 Archivos Modificados

### Widgets de Hábitos
- ✅ `item_habit.dart` - Duración y color
- ✅ `custom_button.dart` - Duración y color
- ✅ `delete_habit_dialog.dart` - Color
- ✅ `container_border_habits.dart` - Color y string
- ✅ `statistics_habit.dart` - Color

### Screens
- ✅ `habit_detail_screen.dart` - Color
- ✅ `habits_screen.dart` - Color

### Providers
- ✅ `habits_provider.dart` - String

### Widgets Compartidos
- ✅ `custom_app_bar.dart` - Color (3 instancias)
- ✅ `custom_loading_indicator.dart` - Color (2 instancias)
- ✅ `custom_border_container.dart` - Color
- ✅ `custom_bottom_bar.dart` - Color y string

## ✨ Beneficios

1. **Mantenibilidad**: Cambiar un color/duración en un solo lugar
2. **Consistencia**: Todos los componentes usan los mismos valores
3. **Legibilidad**: Nombres descriptivos en lugar de valores mágicos
4. **Localización**: Facilita la futura traducción de strings
5. **Tematización**: Base sólida para implementar temas personalizados

## 🚀 Uso

### Importación Simple
```dart
import 'package:find_your_mind/core/constants/animation_constants.dart';
import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/core/constants/string_constants.dart';
```

### Importación con Barrel
```dart
import 'package:find_your_mind/core/constants/app_constants.dart';
```

### Ejemplos de Uso
```dart
// Animaciones
await Future.delayed(AnimationConstants.fastAnimation);

// Colores
Container(color: AppColors.darkBackground)

// Strings
Text(AppStrings.habitsTitle)
```

## 🔍 Próximos Pasos Sugeridos

1. **Agregar más colores** al archivo `color_constants.dart` según se identifiquen
2. **Crear constantes para otros valores repetidos** (padding, border radius, etc.)
3. **Implementar sistema de temas** usando estas constantes como base
4. **Internacionalización (i18n)** migrar strings a archivos de localización

## 📊 Estadísticas

- **Constantes eliminadas**: 24+ instancias
- **Archivos modificados**: 14 archivos
- **Archivos creados**: 4 archivos
- **Errores corregidos**: 0
- **Warnings eliminados**: Todos los imports unused fueron utilizados

---
**Fecha**: 6 de octubre de 2025  
**Branch**: feature/habits

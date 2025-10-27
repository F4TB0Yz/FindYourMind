# Guía de Manejo de Errores - HabitsProvider

## 📋 Resumen de Mejoras Implementadas

Se ha implementado un sistema robusto de manejo de errores en `HabitsProvider` con las siguientes características:

### ✅ Características Implementadas

1. **Sistema de Errores con Estado**
   - `_lastError`: Almacena el último error ocurrido
   - `_lastErrorTime`: Timestamp del error para tracking temporal
   - `_disposed`: Previene operaciones después de dispose

2. **Getters Públicos**
   - `lastError`: Mensaje del último error
   - `lastErrorTime`: Momento en que ocurrió el error
   - `hasError`: Booleano que indica si hay un error activo

3. **Métodos de Gestión**
   - `_setError(String)`: Establece un error y notifica listeners
   - `clearError()`: Limpia el error actual

4. **Validaciones Agregadas**
   - Validación de IDs vacíos
   - Validación de contadores negativos
   - Validación de nombre vacío en creación
   - Validación de meta diaria mayor a 0

5. **Protección contra Memory Leaks**
   - Control de operaciones después de `dispose()`
   - Cancelación de timers en `dispose()`

## 🎯 Uso en la UI

### Opción 1: Banner de Error Persistente

```dart
import 'package:find_your_mind/features/habits/presentation/widgets/error_banner_widget.dart';

// En tu Scaffold
Column(
  children: [
    const ErrorBannerWidget(), // Muestra error si existe
    Expanded(child: YourContent()),
  ],
)
```

### Opción 2: SnackBar Automático

```dart
import 'package:find_your_mind/features/habits/presentation/widgets/error_snackbar_helper.dart';

// En el builder de Consumer
Consumer<HabitsProvider>(
  builder: (context, provider, child) {
    ErrorSnackBarHelper.showErrorIfNeeded(context, provider);
    
    return YourWidget();
  },
)
```

### Opción 3: Manejo Manual

```dart
final provider = context.read<HabitsProvider>();

// Antes de una operación
provider.clearError();

// Después de una operación
if (provider.hasError) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(provider.lastError!)),
  );
}
```

## 📝 Ejemplos de Uso

### Crear Hábito con Manejo de Errores

```dart
Future<void> _createHabit(BuildContext context) async {
  final provider = context.read<HabitsProvider>();
  
  final habitId = await provider.createHabit(newHabit);
  
  if (!mounted) return;
  
  if (habitId != null) {
    ErrorSnackBarHelper.showSuccess(context, 'Hábito creado exitosamente');
    Navigator.pop(context);
  } else if (provider.hasError) {
    // El error ya está en el provider y se mostrará automáticamente
    // si estás usando ErrorBannerWidget o ErrorSnackBarHelper
  }
}
```

### Actualizar Progreso con Feedback

```dart
Future<void> _updateProgress(BuildContext context, HabitProgress progress) async {
  final provider = context.read<HabitsProvider>();
  
  final success = await provider.updateHabitProgress(progress);
  
  if (!mounted) return;
  
  if (success) {
    ErrorSnackBarHelper.showSuccess(context, 'Progreso actualizado');
  }
  // Si falla, el error se muestra automáticamente
}
```

### Sincronizar con Servidor

```dart
Future<void> _syncWithServer(BuildContext context) async {
  final provider = context.read<HabitsProvider>();
  
  final success = await provider.syncWithServer();
  
  if (!mounted) return;
  
  if (success) {
    ErrorSnackBarHelper.showSuccess(context, 'Sincronización exitosa');
  } else {
    ErrorSnackBarHelper.showWarning(
      context, 
      'No se pudo sincronizar en este momento'
    );
  }
}
```

### Eliminar Hábito con Confirmación

```dart
Future<void> _deleteHabit(BuildContext context, String habitId) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirmar eliminación'),
      content: const Text('¿Estás seguro de eliminar este hábito?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  );

  if (confirmed != true || !mounted) return;

  final provider = context.read<HabitsProvider>();
  final success = await provider.deleteHabit(habitId);

  if (!mounted) return;

  if (success) {
    ErrorSnackBarHelper.showSuccess(context, 'Hábito eliminado');
  }
}
```

## 🔍 Verificar Estado de Errores

```dart
Consumer<HabitsProvider>(
  builder: (context, provider, _) {
    // Verificar si hay error
    if (provider.hasError) {
      return ErrorWidget(message: provider.lastError!);
    }
    
    // Verificar cuándo ocurrió
    if (provider.lastErrorTime != null) {
      final minutesAgo = DateTime.now()
        .difference(provider.lastErrorTime!)
        .inMinutes;
      
      if (minutesAgo < 5) {
        // Error reciente
      }
    }
    
    return NormalWidget();
  },
)
```

## 🎨 Widgets Helpers Incluidos

### 1. ErrorBannerWidget

Banner visual que se muestra en la parte superior de la pantalla cuando hay un error.

**Características:**
- Auto-desaparece al cerrar
- Muestra timestamp del error
- Diseño Material con colores de error
- Botón de cierre

### 2. ErrorSnackBarHelper

Helper con métodos estáticos para mostrar diferentes tipos de notificaciones.

**Métodos:**
- `showErrorIfNeeded()`: Muestra error del provider automáticamente
- `showSuccess()`: Mensaje de éxito
- `showWarning()`: Mensaje de advertencia

### 3. HabitsScreenExample

Pantalla de ejemplo completa que demuestra:
- Uso de ErrorBannerWidget
- Integración con ErrorSnackBarHelper
- Pull-to-refresh
- Paginación
- Sincronización manual
- Operaciones CRUD con feedback

## 🚀 Mejores Prácticas

1. **Siempre verificar `mounted`** antes de mostrar UI después de async:
   ```dart
   final result = await someAsyncOperation();
   if (!mounted) return;
   // Actualizar UI
   ```

2. **Limpiar errores antes de operaciones nuevas**:
   ```dart
   provider.clearError();
   await provider.createHabit(habit);
   ```

3. **Proporcionar feedback visual** para todas las operaciones:
   - ✅ Éxito: SnackBar verde
   - ❌ Error: SnackBar rojo (automático)
   - ⚠️ Advertencia: SnackBar naranja

4. **No mostrar errores de sincronización en background**:
   - Los errores de `_syncInBackground()` solo se loguean
   - Solo errores de operaciones del usuario se muestran en UI

## 📊 Beneficios

- ✅ **UX Mejorada**: El usuario siempre sabe qué pasó
- ✅ **Debugging Facilitado**: Errores logueados con timestamps
- ✅ **Código Mantenible**: Validaciones centralizadas
- ✅ **Prevención de Crashes**: Validaciones tempranas
- ✅ **Estado Consistente**: Revertir cambios en caso de error

## 🔧 Personalización

Puedes personalizar los colores y estilos editando:
- `ErrorBannerWidget`: Cambiar diseño del banner
- `ErrorSnackBarHelper`: Modificar duración y estilos de SnackBars

## 📱 Ejemplo Completo

Ver `habits_screen_example.dart` para un ejemplo completo de implementación.

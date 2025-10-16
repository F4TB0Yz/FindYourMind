# 🚀 Guía de Uso del Sistema Offline-First

**Última actualización**: 15 de octubre de 2025  
**Estado**: ✅ Sistema completamente funcional

---

## 📋 Índice

1. [Introducción](#introducción)
2. [Características Principales](#características-principales)
3. [Uso Básico](#uso-básico)
4. [Widgets de Sincronización](#widgets-de-sincronización)
5. [Ejemplos de Código](#ejemplos-de-código)
6. [Manejo de Errores](#manejo-de-errores)
7. [Mejores Prácticas](#mejores-prácticas)

---

## 🎯 Introducción

El sistema offline-first de FindYourMind permite a los usuarios usar la aplicación completamente sin conexión a Internet. Todos los cambios se guardan localmente en SQLite y se sincronizan automáticamente con Supabase cuando hay conexión disponible.

### ✅ ¿Qué está Implementado?

- **Persistencia local**: SQLite como base de datos principal
- **Sincronización automática**: Cambios se envían a Supabase en segundo plano
- **Cola de sincronización**: Operaciones pendientes se procesan automáticamente
- **Manejo de errores robusto**: Pattern Either<Failure, Success>
- **Widgets de UI**: Indicadores de sincronización listos para usar

---

## 🌟 Características Principales

### 1. **Operaciones Instantáneas**

Todas las operaciones CRUD se guardan primero en SQLite:
- ✅ Respuesta inmediata (sin esperas de red)
- ✅ Funciona sin Internet
- ✅ Sincronización transparente en segundo plano

### 2. **Sincronización Inteligente**

- **Automática**: Cada 5 minutos en segundo plano
- **Manual**: Botón de sincronización disponible
- **Al cargar datos**: Sincroniza al obtener hábitos
- **Con reintentos**: Operaciones fallidas se reintentan

### 3. **Gestión de Conflictos**

- Prioridad a cambios locales
- IDs locales se actualizan con IDs remotos
- Marcado de sincronización en cada registro

---

## 📱 Uso Básico

### **En el HabitsProvider**

El provider ya está configurado para usar el sistema offline-first:

```dart
class HabitsProvider extends ChangeNotifier {
  // ✅ Repositorio inyectado desde DependencyInjection
  final HabitRepository _repository = DependencyInjection().habitRepository;
  
  // ... métodos disponibles
}
```

### **Operaciones Disponibles**

#### **1. Crear Hábito**

```dart
final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);

final newHabit = HabitEntity(
  id: '', // Se genera automáticamente
  userId: userId,
  title: 'Leer 30 minutos',
  description: 'Lectura diaria',
  icon: '📚',
  type: TypeHabit.quantity,
  dailyGoal: 30,
  initialDate: DateTime.now().toIso8601String(),
  progress: [],
);

// Crear (funciona offline)
final habitId = await habitsProvider.createHabit(newHabit);

if (habitId != null) {
  print('✅ Hábito creado con ID: $habitId');
} else {
  print('❌ Error al crear hábito');
}
```

#### **2. Actualizar Hábito**

```dart
final updatedHabit = existingHabit.copyWith(
  title: 'Nuevo título',
  dailyGoal: 60,
);

final success = await habitsProvider.updateHabit(updatedHabit);

if (success) {
  print('✅ Hábito actualizado');
} else {
  print('❌ Error al actualizar hábito');
}
```

#### **3. Eliminar Hábito**

```dart
final success = await habitsProvider.deleteHabit(habitId);

if (success) {
  print('✅ Hábito eliminado');
} else {
  print('❌ Error al eliminar hábito');
}
```

#### **4. Actualizar Progreso**

```dart
final updatedProgress = todayProgress.copyWith(
  dailyCounter: todayProgress.dailyCounter + 1,
);

final success = await habitsProvider.updateHabitProgress(updatedProgress);

if (success) {
  print('✅ Progreso actualizado');
} else {
  print('❌ Error al actualizar progreso');
}
```

#### **5. Sincronización Manual**

```dart
final success = await habitsProvider.syncWithServer();

if (success) {
  print('✅ Sincronización exitosa');
} else {
  print('⚠️ No hay cambios o sin conexión');
}
```

#### **6. Obtener Cambios Pendientes**

```dart
final pendingCount = await habitsProvider.getPendingChangesCount();
print('📊 Cambios pendientes: $pendingCount');
```

---

## 🎨 Widgets de Sincronización

### **1. SyncStatusIndicator**

Indicador de estado con botón de sincronización.

**Ubicación**: `lib/features/habits/presentation/widgets/sync_status_indicator.dart`

**Uso en AppBar**:

```dart
AppBar(
  title: Text('Mis Hábitos'),
  actions: [
    SyncStatusIndicator(), // ⭐ Agregar aquí
  ],
)
```

**Características**:
- ✅ Badge con número de cambios pendientes
- ✅ Botón para sincronizar manualmente
- ✅ Animación de carga durante sincronización
- ✅ Mensajes de feedback (SnackBar)
- ✅ Cambio de color según estado

### **2. OfflineModeBanner**

Banner informativo para mostrar estado offline.

**Ubicación**: `lib/features/habits/presentation/widgets/offline_mode_banner.dart`

**Uso en Body**:

```dart
class HabitsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final habitsProvider = Provider.of<HabitsProvider>(context);
    
    return Column(
      children: [
        // ⭐ Banner informativo
        FutureBuilder<int>(
          future: habitsProvider.getPendingChangesCount(),
          builder: (context, snapshot) {
            final pending = snapshot.data ?? 0;
            return OfflineModeBanner(
              pendingChanges: pending,
              onSyncPressed: () async {
                await habitsProvider.syncWithServer();
              },
            );
          },
        ),
        
        // Lista de hábitos
        Expanded(
          child: ListView.builder(...),
        ),
      ],
    );
  }
}
```

**Características**:
- ✅ Solo se muestra si hay cambios pendientes
- ✅ Botón de sincronización integrado
- ✅ Diseño adaptable y atractivo
- ✅ Animaciones suaves

---

## 💡 Ejemplos de Código

### **Ejemplo 1: Crear Hábito con Feedback Completo**

```dart
Future<void> _createNewHabit(BuildContext context) async {
  final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);
  
  final newHabit = HabitEntity(
    id: '',
    userId: 'user-uuid',
    title: _titleController.text,
    description: _descriptionController.text,
    icon: selectedIcon,
    type: selectedType,
    dailyGoal: dailyGoal,
    initialDate: DateTime.now().toIso8601String(),
    progress: [],
  );
  
  // Mostrar loading
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Center(child: CircularProgressIndicator()),
  );
  
  final habitId = await habitsProvider.createHabit(newHabit);
  
  Navigator.pop(context); // Cerrar loading
  
  if (habitId != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ Hábito creado correctamente'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context); // Volver a pantalla anterior
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('❌ Error al crear hábito'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

### **Ejemplo 2: Confirmar Eliminación con Sincronización**

```dart
Future<void> _confirmDeleteHabit(
  BuildContext context,
  String habitId,
  String habitTitle,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Eliminar hábito'),
      content: Text('¿Deseas eliminar "$habitTitle"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text('Eliminar'),
        ),
      ],
    ),
  );
  
  if (confirmed == true) {
    final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);
    final success = await habitsProvider.deleteHabit(habitId);
    
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🗑️ Hábito eliminado'),
          action: SnackBarAction(
            label: 'Sincronizar',
            onPressed: () => habitsProvider.syncWithServer(),
          ),
        ),
      );
    }
  }
}
```

### **Ejemplo 3: Pull-to-Refresh con Sincronización**

```dart
Widget build(BuildContext context) {
  final habitsProvider = Provider.of<HabitsProvider>(context);
  
  return RefreshIndicator(
    onRefresh: () async {
      // Sincronizar primero
      await habitsProvider.syncWithServer();
      // Luego recargar datos
      await habitsProvider.loadHabits();
    },
    child: ListView.builder(
      itemCount: habitsProvider.habits.length,
      itemBuilder: (context, index) {
        return HabitTile(habit: habitsProvider.habits[index]);
      },
    ),
  );
}
```

---

## ⚠️ Manejo de Errores

### **Tipos de Failure**

```dart
// 1. ServerFailure - Error del servidor
ServerFailure(message: 'Error en Supabase')

// 2. NetworkFailure - Sin conexión
NetworkFailure(message: 'Sin conexión a internet')

// 3. CacheFailure - Error en SQLite
CacheFailure(message: 'Error al guardar en base de datos local')
```

### **Pattern Either<Failure, Success>**

Todos los métodos importantes retornan `Either<Failure, T>`:

```dart
final result = await repository.createHabit(habit);

result.fold(
  // Left: Error
  (failure) {
    print('Error: ${failure.message}');
    // Mostrar mensaje al usuario
  },
  // Right: Éxito
  (habitId) {
    print('Éxito! ID: $habitId');
    // Continuar con el flujo
  },
);
```

### **Manejo de Errores en el Provider**

```dart
Future<bool> createHabit(HabitEntity habit) async {
  try {
    final result = await _repository.createHabit(habit);
    
    return result.fold(
      (failure) {
        // Loguear error para debugging
        if (kDebugMode) print('❌ Error: ${failure.message}');
        return false;
      },
      (habitId) {
        // Actualizar estado local
        _habits.insert(0, habit.copyWith(id: habitId));
        notifyListeners();
        return true;
      },
    );
  } catch (e) {
    if (kDebugMode) print('❌ Exception: $e');
    return false;
  }
}
```

---

## 🎓 Mejores Prácticas

### **1. Siempre Usar el Provider**

❌ **INCORRECTO**:
```dart
// No crear instancias manuales
final service = SupabaseHabitsService();
final repo = HabitRepositoryImpl(service);
```

✅ **CORRECTO**:
```dart
// Usar el provider inyectado
final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);
await habitsProvider.createHabit(habit);
```

### **2. No Bloquear la UI**

❌ **INCORRECTO**:
```dart
// Esperar sincronización antes de mostrar datos
await syncWithServer();
await loadHabits(); // Usuario esperando...
```

✅ **CORRECTO**:
```dart
// Cargar datos inmediatamente (desde SQLite)
await loadHabits(); // Instantáneo
// Sincronizar en segundo plano
_syncInBackground(); // No bloquea
```

### **3. Informar al Usuario**

✅ **Mostrar estado de sincronización**:
```dart
AppBar(
  actions: [
    SyncStatusIndicator(), // Siempre visible
  ],
)
```

✅ **Feedback de operaciones**:
```dart
if (success) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('✅ Guardado')),
  );
}
```

### **4. Manejar Contextos Mounted**

```dart
Future<void> _syncData(BuildContext context) async {
  await habitsProvider.syncWithServer();
  
  // ✅ Verificar si el widget sigue montado
  if (!context.mounted) return;
  
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Sincronizado')),
  );
}
```

### **5. Usar Constantes**

```dart
// ✅ Definir en un lugar centralizado
class SyncConstants {
  static const Duration autoSyncInterval = Duration(minutes: 5);
  static const int maxRetries = 3;
  static const Duration syncTimeout = Duration(seconds: 30);
}
```

---

## 🔧 Configuración Avanzada

### **Ajustar Intervalo de Sincronización**

En `HabitsProvider`:

```dart
void _startAutoSync() {
  _syncTimer = Timer.periodic(
    const Duration(minutes: 5), // ⭐ Cambiar aquí
    (_) async {
      await _syncInBackground();
    },
  );
}
```

### **Desactivar Sincronización Automática**

```dart
// En el constructor
HabitsProvider({bool enableAutoSync = true}) {
  if (enableAutoSync) {
    _startAutoSync();
  }
}
```

---

## 📊 Debugging

### **Ver Estado de Sincronización**

```dart
// En consola
final pending = await habitsProvider.getPendingChangesCount();
print('📊 Cambios pendientes: $pending');

// Sincronizar y ver resultado
final result = await habitsProvider.syncWithServer();
print('Resultado: $result');
```

### **Inspeccionar SQLite**

```dart
final db = await DependencyInjection().databaseHelper.database;

// Ver hábitos no sincronizados
final unsynced = await db.query('habits', where: 'synced = 0');
print('Hábitos sin sincronizar: ${unsynced.length}');

// Ver cola de sincronización
final pending = await db.query('pending_sync');
print('Operaciones pendientes: ${pending.length}');
```

---

## 🎯 Resumen

- ✅ **Sistema completamente funcional** y listo para usar
- ✅ **Widgets de UI** disponibles para integración inmediata
- ✅ **Manejo de errores robusto** con pattern Either
- ✅ **Sincronización automática** cada 5 minutos
- ✅ **Funciona offline** sin problemas
- ✅ **Código siguiendo mejores prácticas**

---

**¿Necesitas más ayuda?** Consulta:
- `/docs/SYNC_SERVICE_USAGE_ANALYSIS.md` - Análisis completo del sistema
- `/docs/OFFLINE_SYNC_SYSTEM.md` - Documentación técnica detallada
- `/lib/core/services/sync_service.dart` - Código fuente del servicio

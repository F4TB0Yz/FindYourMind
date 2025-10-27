# Migración de Lógica de Sincronización a SyncProvider

## 📋 Resumen
Se ha refactorizado la arquitectura de sincronización moviendo toda la lógica de sync desde `HabitsProvider` a un nuevo `SyncProvider` dedicado. Esto mejora la separación de responsabilidades y hace el código más mantenible.

## 🎯 Objetivos Cumplidos
- ✅ Separar la lógica de sincronización en un provider dedicado
- ✅ Mantener la funcionalidad offline-first intacta
- ✅ Simplificar `HabitsProvider` para enfocarse solo en gestión de hábitos
- ✅ Centralizar el estado de sincronización en toda la app

## 🔧 Cambios Realizados

### 1. Nuevo `SyncProvider` (`lib/shared/presentation/providers/sync_provider.dart`)

**Responsabilidades:**
- ✨ Sincronización automática cada 5 minutos
- ✨ Sincronización manual bajo demanda
- ✨ Gestión del estado de sincronización (`isSyncing`)
- ✨ Contador de cambios pendientes
- ✨ Tracking de última sincronización
- ✨ Manejo de errores de sincronización
- ✨ Callbacks para notificar a otros providers

**Propiedades:**
```dart
bool isSyncing                    // Estado de sincronización activa
int pendingChangesCount           // Cambios pendientes de sincronizar
DateTime? lastSyncTime            // Última sincronización exitosa
String? lastSyncError             // Último error de sincronización
bool hasError                     // Si hay un error activo
```

**Métodos principales:**
```dart
Future<bool> syncWithServer()                    // Sincronización manual
Future<int> getPendingChangesCount()             // Obtener contador
void setOnSyncCompleteCallback(VoidCallback)     // Registrar callback
void markPendingChanges()                        // Marcar cambios nuevos
void clearError()                                // Limpiar errores
```

### 2. `HabitsProvider` Simplificado

**Eliminado:**
- ❌ `_isSyncing` - Movido a `SyncProvider`
- ❌ `_syncTimer` - Movido a `SyncProvider`
- ❌ `_autoSyncInterval` - Movido a `SyncProvider`
- ❌ `_syncDelay` - Movido a `SyncProvider`
- ❌ `_refreshDelay` - Movido a `SyncProvider`
- ❌ `_startAutoSync()` - Movido a `SyncProvider`
- ❌ `_syncInBackground()` - Movido a `SyncProvider`
- ❌ `syncWithServer()` - Movido a `SyncProvider`
- ❌ `getPendingChangesCount()` - Movido a `SyncProvider`

**Agregado:**
- ✅ `refreshHabitsFromLocal()` - Método público para recargar desde SQLite (llamado por `SyncProvider`)

**Mantenido:**
- ✅ Todas las operaciones CRUD (create, update, delete)
- ✅ Paginación
- ✅ Gestión de estado de UI
- ✅ Manejo de errores

### 3. `SyncStatusIndicator` Widget Actualizado

**Antes:**
- Usaba `FutureBuilder` para obtener el contador
- Mantenía estado local `_isSyncing`
- Llamaba a `habitsProvider.syncWithServer()`

**Después:**
- Usa `Consumer<SyncProvider>` para estado reactivo
- Estado centralizado en `SyncProvider`
- Llamada directa a `syncProvider.syncWithServer()`
- Más eficiente y reactivo

### 4. `HabitsScreen` Actualizado

**Banner de Modo Offline:**
```dart
// Antes
FutureBuilder<int>(
  future: habitsProvider.getPendingChangesCount(),
  builder: (context, snapshot) {
    final pendingCount = snapshot.data ?? 0;
    return OfflineModeBanner(
      pendingChanges: pendingCount,
      onSyncPressed: () async {
        await habitsProvider.syncWithServer();
        setState(() {}); // Forzar rebuild
      },
    );
  },
)

// Después
Consumer<SyncProvider>(
  builder: (context, syncProvider, _) {
    return OfflineModeBanner(
      pendingChanges: syncProvider.pendingChangesCount,
      onSyncPressed: () async {
        await syncProvider.syncWithServer();
      },
    );
  },
)
```

### 5. `main.dart` - Integración de Providers

**Providers agregados:**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ChangeNotifierProvider(create: (_) => ScreensProvider(...)),
    ChangeNotifierProvider(create: (_) => NewHabitProvider()),
    ChangeNotifierProvider(create: (_) => HabitsProvider()),
    ChangeNotifierProvider(create: (_) => SyncProvider()), // ✨ NUEVO
  ],
  child: const MainApp(),
)
```

**Conexión entre providers:**
```dart
@override
void initState() {
  super.initState();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);
    final syncProvider = Provider.of<SyncProvider>(context, listen: false);
    
    // ✨ Conectar SyncProvider con HabitsProvider
    syncProvider.setOnSyncCompleteCallback(() {
      habitsProvider.refreshHabitsFromLocal();
    });
    
    // Cargar hábitos iniciales
    habitsProvider.loadHabits();
  });  
}
```

## 🔄 Flujo de Sincronización

### Sincronización Automática (cada 5 minutos)
```
SyncProvider
  └─> _syncInBackground()
       ├─> HabitRepositoryImpl.syncWithRemote()
       │    ├─> SyncService.syncPendingChanges()
       │    └─> Actualizar SQLite con datos remotos
       └─> Callback: habitsProvider.refreshHabitsFromLocal()
            └─> Recargar hábitos desde SQLite
            └─> notifyListeners() → UI actualizada
```

### Sincronización Manual (botón)
```
Usuario presiona botón sync
  └─> SyncStatusIndicator
       └─> syncProvider.syncWithServer()
            ├─> HabitRepositoryImpl.syncWithRemote()
            │    ├─> SyncService.syncPendingChanges()
            │    └─> Actualizar SQLite
            ├─> Callback: habitsProvider.refreshHabitsFromLocal()
            └─> Mostrar SnackBar con resultado
```

### Operación CRUD (ej. crear hábito)
```
Usuario crea hábito
  └─> habitsProvider.createHabit()
       ├─> Actualizar lista local
       ├─> HabitRepositoryImpl.createHabit()
       │    ├─> Guardar en SQLite
       │    └─> Intentar guardar en Supabase
       │         └─> Si falla: SyncService.markPendingSync()
       └─> notifyListeners()

SyncProvider (automático después)
  └─> Detecta cambios pendientes
  └─> Sincroniza en siguiente ciclo (5 min)
```

## 📊 Beneficios de la Refactorización

### 1. **Separación de Responsabilidades**
- `HabitsProvider` → Solo gestión de hábitos
- `SyncProvider` → Solo sincronización
- Código más limpio y mantenible

### 2. **Reutilización**
- `SyncProvider` puede usarse en otros features (notas, tareas, etc.)
- Lógica de sincronización centralizada

### 3. **Testing**
- Más fácil hacer unit tests
- Providers aislados con responsabilidades claras

### 4. **Estado Reactivo**
- UI se actualiza automáticamente con `Consumer`
- No más `FutureBuilder` para estado de sincronización
- Menos rebuilds innecesarios

### 5. **Escalabilidad**
- Fácil agregar nuevas features de sincronización
- Estructura preparada para múltiples tipos de datos

## 🧪 Testing Recomendado

### Escenarios a Probar:
1. ✅ Sincronización automática cada 5 minutos
2. ✅ Sincronización manual desde el botón
3. ✅ Crear hábito offline → Sincronizar después
4. ✅ Actualizar hábito con internet
5. ✅ Eliminar hábito offline → Marcar para sync
6. ✅ Badge de cambios pendientes actualizado
7. ✅ Recarga de UI después de sync exitosa
8. ✅ Manejo de errores de sincronización

## 🔍 Archivos Modificados

1. **Creado:**
   - `lib/shared/presentation/providers/sync_provider.dart` (nuevo provider)

2. **Modificado:**
   - `lib/features/habits/presentation/providers/habits_provider.dart`
   - `lib/features/habits/presentation/widgets/sync_status_indicator.dart`
   - `lib/features/habits/presentation/screens/habits_screen.dart`
   - `lib/main.dart`

## 🚀 Próximos Pasos (Opcional)

1. **Agregar indicador de última sincronización**
   ```dart
   Text('Última sync: ${syncProvider.lastSyncTime}')
   ```

2. **Mostrar errores de sincronización**
   ```dart
   if (syncProvider.hasError) {
     ErrorBanner(message: syncProvider.lastSyncError)
   }
   ```

3. **Sincronización específica por tipo**
   ```dart
   syncProvider.syncHabits()
   syncProvider.syncNotes()
   ```

4. **Métricas de sincronización**
   ```dart
   SyncMetrics(
     totalSyncs: syncProvider.totalSyncs,
     successRate: syncProvider.successRate,
   )
   ```

## ✅ Conclusión

La migración ha sido exitosa. La lógica de sincronización está ahora centralizada en `SyncProvider`, mientras que `HabitsProvider` se enfoca exclusivamente en la gestión de hábitos. Esto mejora la arquitectura, facilita el mantenimiento y prepara el código para futuras expansiones.

**Estado:** ✅ Completado y sin errores de compilación
**Fecha:** 26 de octubre de 2025

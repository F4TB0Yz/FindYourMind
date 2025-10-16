# Solución al Error "Unsupported operation: read-only" en Windows

## 🐛 Problema
La aplicación presentaba el error `CacheException: Error al obtener hábitos: Unsupported operation: read-only` al intentar leer desde SQLite en Windows, especialmente cuando no había conexión WiFi.

## 🔍 Causa Raíz
`sqflite_ffi` tenía problemas al abrir la base de datos en modo escritura en Windows. A pesar de especificar `readOnly: false`, la base de datos se abría en modo solo lectura.

## ✅ Solución Aplicada

### 1. **Paquetes Agregados**
Agregamos `sqlite3_flutter_libs` para mejor soporte de SQLite en Windows:

```yaml
dependencies:
  sqlite3_flutter_libs: ^0.5.24
  drift: ^2.23.0
  drift_sqflite: ^2.0.0
  path: ^1.9.0
  path_provider: ^2.1.5

dev_dependencies:
  build_runner: ^2.4.15
  drift_dev: ^2.23.0
```

### 2. **Cambios en `database_helper.dart`**

#### Imports actualizados:
```dart
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
```

#### Inicialización mejorada de FFI:
```dart
static void initializeFfi() {
  if (_ffiInitialized) return;
  
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // Inicializar las librerías nativas de sqlite3
    applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    
    // Inicializar sqflite_ffi para desktop
    sqfliteFfiInit();
    
    // Usar la factory de FFI
    databaseFactory = databaseFactoryFfi;
    
    print('✅ [DB] sqflite_ffi inicializado para ${Platform.operatingSystem}');
    _ffiInitialized = true;
  }
}
```

#### Método `_initDatabase()` simplificado:
```dart
Future<Database> _initDatabase() async {
  final path = await _getDatabasePath();
  
  print('📂 [DB] Plataforma: Desktop (${Platform.operatingSystem})');
  print('📂 [DB] Ruta de la base de datos: $path');

  try {
    // Usar openDatabase con la factory configurada
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onOpen: _onOpen,
      readOnly: false,
      singleInstance: true,
    );
    
    print('✅ [DB] Base de datos abierta correctamente');
    return db;
  } catch (e) {
    print('❌ [DB] Error abriendo base de datos: $e');
    rethrow;
  }
}
```

### 3. **Método `_getDatabasePath()` mejorado**
Ahora inicializa FFI antes de obtener la ruta:

```dart
Future<String> _getDatabasePath() async {
  // Asegurar que FFI esté inicializado ANTES de obtener la ruta
  initializeFfi();
  final databasesPath = await getDatabasesPath();
  return join(databasesPath, 'find_your_mind.db');
}
```

## 🧪 Pruebas Realizadas

### ✅ Con WiFi
- Los hábitos se cargan desde Supabase
- Se guardan correctamente en SQLite local
- No hay errores de "read-only"

### ✅ Sin WiFi
- Los hábitos se cargan desde SQLite local
- Se pueden crear, actualizar y eliminar hábitos
- Los cambios se guardan localmente y se sincronizan cuando hay conexión

## 📝 Notas Importantes

1. **Primera ejecución**: Al iniciar por primera vez, si hay `forceResetDatabase: true` en `main.dart`, se eliminará y recreará la base de datos.

2. **Quitar el flag temporal**: Después de que funcione correctamente, cambiar en `main.dart`:
   ```dart
   // De esto:
   await DependencyInjection().initialize(forceResetDatabase: true);
   
   // A esto:
   await DependencyInjection().initialize();
   ```

3. **Limpieza manual**: Si persisten problemas, eliminar manualmente:
   ```powershell
   Remove-Item -Path "C:\Users\jfdua\Documents\flutter\find_your_mind\.dart_tool\sqflite_common_ffi\databases\find_your_mind.db" -Force
   ```

## 🎯 Resultado

✅ **Offline-first funcional**: La aplicación ahora funciona correctamente tanto con WiFi como sin WiFi en Windows.

✅ **Sincronización automática**: Los cambios se sincronizan automáticamente cuando hay conexión.

✅ **Sin errores de "read-only"**: La base de datos se abre correctamente en modo escritura.

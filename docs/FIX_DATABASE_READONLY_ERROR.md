# Fix: Database Read-Only Error en SQLite FFI

## 🐛 Problema

```
❌ [PROVIDER] Error loadHabits: CacheException: 
Error al obtener hábitos: Unsupported operation: read-only
```

### Causa

Cuando se usa `sqflite_common_ffi` en Windows/Desktop, la base de datos se puede abrir en modo **read-only** si no se configuran correctamente las opciones de apertura. Esto impide cualquier operación de escritura (INSERT, UPDATE, DELETE).

**Razones comunes:**
1. No especificar explícitamente `readOnly: false`
2. Usar `openDatabase()` en lugar de `databaseFactory.openDatabase()`
3. La base de datos no existe y no se llama correctamente `onCreate`
4. Problemas de permisos en la ruta de la base de datos

## ✅ Solución Implementada

### 1. Usar `databaseFactory.openDatabase()` con Opciones Explícitas

**Archivo:** `lib/core/config/database_helper.dart`

**Antes:**
```dart
return await openDatabase(
  path,
  version: 1,
  onCreate: _onCreate,
);
```

**Después:**
```dart
return await databaseFactory.openDatabase(
  path,
  options: OpenDatabaseOptions(
    version: 1,
    onCreate: _onCreate,
    readOnly: false,        // ← CLAVE: Modo lectura/escritura
    singleInstance: true,   // ← Una sola instancia de la BD
  ),
);
```

### 2. Logs de Debug para Diagnóstico

Agregamos logs en puntos clave:

```dart
Future<Database> _initDatabase() async {
  // ...logs de plataforma y ruta...
  
  print('📂 [DB] Plataforma: Desktop (${Platform.operatingSystem})');
  print('📂 [DB] Ruta de la base de datos: $path');
  
  try {
    final db = await databaseFactory.openDatabase(...);
    print('✅ [DB] Base de datos abierta correctamente');
    return db;
  } catch (e) {
    print('❌ [DB] Error abriendo base de datos: $e');
    rethrow;
  }
}
```

### 3. Logs en onCreate para Verificar Creación

```dart
Future<void> _onCreate(Database db, int version) async {
  print('🔨 [DB] Creando tablas de la base de datos...');
  
  await db.execute('CREATE TABLE habits (...)');
  print('✅ [DB] Tabla habits creada');
  
  await db.execute('CREATE TABLE habit_progress (...)');
  print('✅ [DB] Tabla habit_progress creada');
  
  await db.execute('CREATE TABLE pending_sync (...)');
  print('✅ [DB] Tabla pending_sync creada');
  
  // Índices...
  print('✅ [DB] Índices creados');
  print('🎉 [DB] Base de datos inicializada correctamente');
}
```

## 🔍 Diagnóstico del Problema

### Secuencia de Logs Esperada (Primera Ejecución):

```
✅ [DB] sqflite_ffi inicializado para windows
📂 [DB] Plataforma: Desktop (windows)
📂 [DB] Ruta de la base de datos: C:\Users\...\find_your_mind.db
🔨 [DB] Creando tablas de la base de datos...
✅ [DB] Tabla habits creada
✅ [DB] Tabla habit_progress creada
✅ [DB] Tabla pending_sync creada
✅ [DB] Índices creados
🎉 [DB] Base de datos inicializada correctamente
✅ [DB] Base de datos abierta correctamente
```

### Secuencia de Logs Esperada (Ejecuciones Subsecuentes):

```
✅ [DB] sqflite_ffi inicializado para windows
📂 [DB] Plataforma: Desktop (windows)
📂 [DB] Ruta de la base de datos: C:\Users\...\find_your_mind.db
✅ [DB] Base de datos abierta correctamente
(onCreate NO se llama porque la BD ya existe)
```

## 🔧 Cambios Realizados

### Resumen de Modificaciones

| Cambio | Antes | Después | Razón |
|--------|-------|---------|-------|
| **Método de apertura** | `openDatabase()` | `databaseFactory.openDatabase()` | Compatibilidad con FFI |
| **Opciones explícitas** | Parámetros sueltos | `OpenDatabaseOptions()` | Control total |
| **readOnly** | No especificado | `false` | Permitir escritura |
| **singleInstance** | No especificado | `true` | Evitar conflictos |
| **Logs** | Ninguno | Múltiples puntos | Debugging |

### Código Completo del Fix

```dart
Future<Database> _initDatabase() async {
  String path;
  
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    final databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'find_your_mind.db');
    print('📂 [DB] Plataforma: Desktop (${Platform.operatingSystem})');
    print('📂 [DB] Ruta de la base de datos: $path');
  } else {
    final databasesPath = await getDatabasesPath();
    path = join(databasesPath, 'find_your_mind.db');
    print('📂 [DB] Plataforma: Móvil');
    print('📂 [DB] Ruta de la base de datos: $path');
  }

  try {
    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
        readOnly: false,      // ← FIX PRINCIPAL
        singleInstance: true,
      ),
    );
    
    print('✅ [DB] Base de datos abierta correctamente');
    return db;
  } catch (e) {
    print('❌ [DB] Error abriendo base de datos: $e');
    rethrow;
  }
}
```

## 📊 Comparación Antes/Después

### ❌ ANTES (Con Error)
```
📂 [DB] Ruta: C:\Users\...\find_your_mind.db
❌ Error: Unsupported operation: read-only
```

### ✅ DESPUÉS (Funcional)
```
✅ [DB] sqflite_ffi inicializado para windows
📂 [DB] Plataforma: Desktop (windows)
📂 [DB] Ruta: C:\Users\...\find_your_mind.db
🔨 [DB] Creando tablas...
✅ [DB] Tabla habits creada
✅ [DB] Tabla habit_progress creada
✅ [DB] Tabla pending_sync creada
✅ [DB] Índices creados
🎉 [DB] Base de datos inicializada correctamente
✅ [DB] Base de datos abierta correctamente
```

## 🎯 Verificación del Fix

### Test 1: Primera Ejecución (BD No Existe)
```dart
1. App inicia
2. DependencyInjection.initialize()
3. DatabaseHelper.database getter
4. initializeFfi() → Configura sqflite_ffi
5. _initDatabase()
6. databaseFactory.openDatabase()
7. onCreate() se llama → Crea tablas
8. ✅ BD lista para usar
```

### Test 2: Ejecución Subsecuente (BD Existe)
```dart
1. App inicia
2. DatabaseHelper.database getter
3. initializeFfi() → Ya inicializado, return
4. _initDatabase()
5. databaseFactory.openDatabase()
6. onCreate() NO se llama (BD ya existe)
7. ✅ BD abierta en modo lectura/escritura
```

### Test 3: Operaciones CRUD
```dart
// Insertar
✅ await db.insert('habits', data);

// Actualizar
✅ await db.update('habits', data, where: 'id = ?');

// Eliminar
✅ await db.delete('habits', where: 'id = ?');

// Leer
✅ final results = await db.query('habits');
```

## 🐛 Solución de Problemas

### Si aún aparece "read-only":

**1. Verificar permisos de la carpeta:**
```bash
# Windows PowerShell
Get-Acl "C:\Users\<usuario>\AppData\Local\find_your_mind"
```

**2. Eliminar base de datos corrupta:**
```dart
// Agregar método temporal en DatabaseHelper
Future<void> deleteDatabase() async {
  final path = join(await getDatabasesPath(), 'find_your_mind.db');
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
    print('🗑️ Base de datos eliminada');
  }
}

// Llamar una vez desde main() antes de initialize()
await DatabaseHelper().deleteDatabase();
```

**3. Usar ruta alternativa:**
```dart
// En lugar de getDatabasesPath()
import 'package:path_provider/path_provider.dart';

final appDocDir = await getApplicationDocumentsDirectory();
final path = join(appDocDir.path, 'find_your_mind.db');
```

## 📝 Notas Importantes

### Diferencias entre Plataformas

| Aspecto | Android/iOS (sqflite) | Windows/Linux (sqflite_ffi) |
|---------|----------------------|------------------------------|
| **Inicialización** | Automática | Requiere `sqfliteFfiInit()` |
| **Factory** | `databaseFactory` predefinido | Debe asignarse `databaseFactoryFfi` |
| **Opciones** | Parámetros directos funciona | Requiere `OpenDatabaseOptions` |
| **Ruta** | Sandboxed automático | Puede tener problemas de permisos |

### Best Practices

✅ **Hacer:**
- Usar `databaseFactory.openDatabase()` con opciones explícitas
- Especificar `readOnly: false` para operaciones de escritura
- Agregar logs para debugging
- Manejar errores con try-catch

❌ **Evitar:**
- Usar `openDatabase()` directamente en desktop
- Omitir `readOnly: false`
- Asumir que onCreate se llama siempre
- Ignorar errores de apertura

## ✅ Estado Final

**Problema:** ❌ Database read-only en Windows  
**Solución:** ✅ Usar `databaseFactory.openDatabase()` con `OpenDatabaseOptions`  
**Resultado:** ✅ Base de datos funcional en lectura/escritura  
**Plataformas:** ✅ Windows, Linux, macOS, Android, iOS

---

**Fecha:** 2025-10-14  
**Problema:** Unsupported operation: read-only  
**Causa:** Opciones incorrectas en sqflite_ffi  
**Solución:** OpenDatabaseOptions con readOnly: false  
**Estado:** ✅ RESUELTO

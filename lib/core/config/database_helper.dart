import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:path/path.dart' show join;
import 'dart:io' show Platform, File;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static bool _ffiInitialized = false;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  /// Elimina la base de datos existente (útil para desarrollo/debugging)
  Future<void> deleteDatabaseFile() async {
    try {
      // Cerrar la base de datos primero si está abierta
      if (_database != null) {
        await _database!.close();
        _database = null;
      }

      // Esperar un momento para asegurar que el archivo se libere
      await Future.delayed(const Duration(milliseconds: 500));

      // Inicializar FFI
      initializeFfi();

      final path = await _getDatabasePath();
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
        AppLogger.i('🗑️ [DB] Base de datos eliminada: $path');
      } else {
        AppLogger.i('ℹ️ [DB] No existe base de datos para eliminar');
      }
    } catch (e) {
      AppLogger.e('Error eliminando base de datos', error: e);
      rethrow;
    }
  }

  /// Inicializa sqflite_ffi para plataformas desktop (Windows, Linux, macOS)
  static void initializeFfi() {
    if (_ffiInitialized) return;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      // Inicializar las librerías nativas de sqlite3
      applyWorkaroundToOpenSqlite3OnOldAndroidVersions();

      // Inicializar sqflite_ffi para desktop
      sqfliteFfiInit();

      // Usar la factory de FFI
      databaseFactory = databaseFactoryFfi;

      AppLogger.i('✅ [DB] sqflite_ffi inicializado para ${Platform.operatingSystem}');
      _ffiInitialized = true;
    }
  }

  Future<String> _getDatabasePath() async {
    // Asegurar que FFI esté inicializado ANTES de obtener la ruta
    initializeFfi();
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, 'find_your_mind.db');
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Asegurar que FFI esté inicializado antes de abrir la BD
    initializeFfi();

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await _getDatabasePath();

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      AppLogger.d('📂 [DB] Plataforma: Desktop (${Platform.operatingSystem})');
    } else {
      AppLogger.d('📂 [DB] Plataforma: Móvil');
    }
    AppLogger.d('📂 [DB] Ruta de la base de datos: $path');

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

      AppLogger.i('✅ [DB] Base de datos abierta correctamente');
      return db;
    } catch (e) {
      AppLogger.e('Error abriendo base de datos', error: e);
      rethrow;
    }
  }

  Future<void> _onOpen(Database db) async {
    AppLogger.d('🔍 [DB] Verificando integridad de la base de datos...');

    try {
      // Verificar si las tablas principales existen
      final result = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name IN ('habits', 'habit_progress', 'pending_sync')",
      );

      if (result.length < 3) {
        AppLogger.w('Tablas faltantes detectadas. Recreando...');

        // Eliminar tablas existentes si las hay
        await db.execute('DROP TABLE IF EXISTS pending_sync');
        await db.execute('DROP TABLE IF EXISTS habit_progress');
        await db.execute('DROP TABLE IF EXISTS habits');

        // Recrear todas las tablas
        await _onCreate(db, 1);
      } else {
        await _ensurePerformanceIndexes(db);
        AppLogger.i('✅ [DB] Todas las tablas existen correctamente');
      }
    } catch (e) {
      AppLogger.e('Error verificando tablas', error: e);
      // Si hay error, intentar recrear
      try {
        await _onCreate(db, 1);
      } catch (e2) {
        AppLogger.e('Error recreando tablas', error: e2);
        rethrow;
      }
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    AppLogger.i('🔨 [DB] Creando tablas de la base de datos...');

    // Tabla de hábitos
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        type TEXT NOT NULL,
        daily_goal INTEGER NOT NULL,
        initial_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        synced INTEGER DEFAULT 0,
        updated_at TEXT NOT NULL
      )
    ''');
    AppLogger.i('✅ [DB] Tabla habits creada');

    // Tabla de progreso de hábitos
    await db.execute('''
      CREATE TABLE habit_progress (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        date TEXT NOT NULL,
        daily_goal INTEGER NOT NULL,
        daily_counter INTEGER NOT NULL,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (habit_id) REFERENCES habits (id) ON DELETE CASCADE,
        UNIQUE(habit_id, date)
      )
    ''');
    AppLogger.i(
      '✅ [DB] Tabla habit_progress creada con restricción UNIQUE(habit_id, date)',
    );

    // Tabla de sincronización pendiente
    await db.execute('''
      CREATE TABLE pending_sync (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        action TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at TEXT NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');
    AppLogger.i('✅ [DB] Tabla pending_sync creada');

    await _ensurePerformanceIndexes(db);

    AppLogger.i('✅ [DB] Índices creados');
    AppLogger.i('🎉 [DB] Base de datos inicializada correctamente');
  }

  Future<void> _ensurePerformanceIndexes(Database db) async {
    // Índice compuesto para consultas de hábitos por usuario ordenados por fecha.
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_habits_user_initial_date '
      'ON habits(user_id, initial_date DESC)',
    );

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_habit_progress_habit_id '
      'ON habit_progress(habit_id)',
    );

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_habit_progress_date '
      'ON habit_progress(date)',
    );

    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pending_sync_entity '
      'ON pending_sync(entity_type, entity_id)',
    );
  }

  /// Limpia todas las tablas de la base de datos (útil al cerrar sesión)
  /// Mantiene la estructura pero elimina todos los datos
  Future<void> clearAllTables() async {
    AppLogger.i('🧹 [DB] Limpiando todas las tablas...');

    try {
      final db = await database;

      // Eliminar todos los datos de las tablas
      await db.delete('habits');
      await db.delete('habit_progress');
      await db.delete('pending_sync');

      AppLogger.i('✅ [DB] Todas las tablas limpiadas exitosamente');
    } catch (e) {
      AppLogger.e('Error al limpiar tablas', error: e);
      rethrow;
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// Table definitions
// ---------------------------------------------------------------------------

class HabitsTable extends Table {
  @override
  String get tableName => 'habits';

  TextColumn get id => text()();
  TextColumn get userId => text().named('user_id')();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get icon => text()();
  TextColumn get type => text()();
  IntColumn get dailyGoal => integer().named('daily_goal')();
  TextColumn get initialDate => text().named('initial_date')();
  TextColumn get createdAt => text().named('created_at')();
  IntColumn get synced => integer().withDefault(const Constant(0))();
  TextColumn get updatedAt => text().named('updated_at')();

  @override
  Set<Column> get primaryKey => {id};
}

class HabitProgressTable extends Table {
  @override
  String get tableName => 'habit_progress';

  TextColumn get id => text()();
  TextColumn get habitId => text()
      .named('habit_id')
      .references(HabitsTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get date => text()();
  IntColumn get dailyGoal => integer().named('daily_goal')();
  IntColumn get dailyCounter => integer().named('daily_counter')();
  IntColumn get synced => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {habitId, date},
      ];
}

class PendingSyncTable extends Table {
  @override
  String get tableName => 'pending_sync';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();
  // 'action' is a reserved SQL keyword; alias in Dart as actionType.
  TextColumn get actionType => text().named('action')();
  TextColumn get data => text()();
  TextColumn get createdAt => text().named('created_at')();
  IntColumn get retryCount =>
      integer().named('retry_count').withDefault(const Constant(0))();
}

// ---------------------------------------------------------------------------
// Database
// ---------------------------------------------------------------------------

@DriftDatabase(tables: [HabitsTable, HabitProgressTable, PendingSyncTable])
class AppDatabase extends _$AppDatabase {
  static AppDatabase? _instance;

  AppDatabase._internal() : super(_openConnection());

  factory AppDatabase() {
    _instance ??= AppDatabase._internal();
    return _instance!;
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createIndexes();
          AppLogger.i('✅ [DB] AppDatabase inicializada');
        },
        beforeOpen: (_) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _createIndexes() async {
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_habits_user_initial_date '
      'ON habits(user_id, initial_date DESC)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_habit_progress_habit_id '
      'ON habit_progress(habit_id)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_habit_progress_date '
      'ON habit_progress(date)',
    );
    await customStatement(
      'CREATE INDEX IF NOT EXISTS idx_pending_sync_entity '
      'ON pending_sync(entity_type, entity_id)',
    );
  }

  Future<void> clearAllTables() async {
    await delete(pendingSyncTable).go();
    await delete(habitProgressTable).go();
    await delete(habitsTable).go();
    AppLogger.i('✅ [DB] Tablas limpiadas');
  }

  Future<void> deleteDatabaseFile() async {
    if (_instance != null) {
      await _instance!.close();
      _instance = null;
    }
    final file = await _dbFile();
    if (await file.exists()) {
      await file.delete();
      AppLogger.i('🗑️ [DB] Base de datos eliminada: ${file.path}');
    }
  }

  // No-op kept for call-site compatibility; NativeDatabase needs no init.
  static void initializeFfi() {}
}

Future<File> _dbFile() async {
  final dir = await getApplicationDocumentsDirectory();
  return File(p.join(dir.path, 'find_your_mind.db'));
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // Required on old Android versions to load the bundled sqlite3 binary.
    applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    final file = await _dbFile();
    return NativeDatabase.createInBackground(file);
  });
}

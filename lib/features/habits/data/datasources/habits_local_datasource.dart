import 'package:drift/drift.dart';
import 'package:find_your_mind/core/database/app_database.dart';
import 'package:find_your_mind/core/error/exceptions.dart';
import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:find_your_mind/features/habits/data/models/habit_category_model.dart';
import 'package:find_your_mind/features/habits/data/models/habit_tracking_type_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:uuid/uuid.dart';

abstract class HabitsLocalDatasource {
  Future<List<HabitEntity>> getHabitsByUserId(String userId);

  Future<List<HabitEntity>> getHabitsByUserIdPaginated({
    required String userId,
    int limit = 10,
    int offset = 0,
  });

  Future<String?> createHabit(HabitEntity habit);

  Future<void> updateHabit(HabitEntity habit);

  Future<void> deleteHabit(String habitId);

  Future<String?> createHabitLog(HabitLog habitLog);

  Future<void> deleteHabitLogs(String habitId);

  Future<void> updateHabitLogValue({
    required String habitId,
    required String logId,
    required int value,
  });

  Future<HabitLog?> getHabitLogById(String logId);

  Future<void> deleteHabitPendingSync(String habitId);

  Future<void> clearAllHabits(String userId);

  Future<void> saveHabits(List<HabitEntity> habits);
}

class HabitsLocalDatasourceImpl implements HabitsLocalDatasource {
  final AppDatabase _db;
  static const int _startupLogsLimitPerHabit = 30;

  HabitsLocalDatasourceImpl({required AppDatabase databaseHelper})
      : _db = databaseHelper;

  Future<Map<String, List<HabitLogsTableData>>> _loadLogsByHabitIds(
    List<String> habitIds, {
    int? maxPerHabit,
  }) async {
    if (habitIds.isEmpty) return {};

    final rows = await (_db.select(_db.habitLogsTable)
          ..where((t) => t.habitId.isIn(habitIds))
          ..orderBy([
            (t) => OrderingTerm.asc(t.habitId),
            (t) => OrderingTerm.desc(t.date),
          ]))
        .get();

    final Map<String, List<HabitLogsTableData>> grouped = {};
    for (final row in rows) {
      final list = grouped.putIfAbsent(row.habitId, () => []);
      if (maxPerHabit == null || list.length < maxPerHabit) {
        list.add(row);
      }
    }
    return grouped;
  }

  HabitEntity _rowToEntity(
    HabitsTableData row,
    List<HabitLogsTableData> logs,
  ) {
    return HabitEntity(
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      icon: row.icon,
      category: HabitCategoryModel.fromString(row.category),
      trackingType: HabitTrackingTypeModel.fromString(row.trackingType),
      targetValue: row.targetValue,
      initialDate: row.initialDate,
      logs: logs
          .map(
            (log) => HabitLog(
              id: log.id,
              habitId: log.habitId,
              date: log.date,
              value: log.value,
            ),
          )
          .toList(),
    );
  }

  @override
  Future<List<HabitEntity>> getHabitsByUserId(String userId) async {
    try {
      AppLogger.d('[LOCAL_DS] getHabitsByUserId - userId: $userId');

      final habitRows = await (_db.select(_db.habitsTable)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.initialDate)]))
          .get();

      final habitIds = habitRows.map((row) => row.id).toList();
      final logsByHabit = await _loadLogsByHabitIds(habitIds);

      return habitRows
          .map((row) => _rowToEntity(row, logsByHabit[row.id] ?? []))
          .toList();
    } catch (e, st) {
      AppLogger.e(
        '[LOCAL_DS] getHabitsByUserId - Error: ${e.runtimeType}',
        error: e,
        stackTrace: st,
      );
      throw CacheException('Error al obtener hábitos: ${e.toString()}');
    }
  }

  @override
  Future<List<HabitEntity>> getHabitsByUserIdPaginated({
    required String userId,
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      AppLogger.d(
        '[LOCAL_DS] getHabitsByUserIdPaginated - userId: $userId, limit: $limit, offset: $offset',
      );

      final habitRows = await (_db.select(_db.habitsTable)
            ..where((t) => t.userId.equals(userId))
            ..orderBy([(t) => OrderingTerm.desc(t.initialDate)])
            ..limit(limit, offset: offset))
          .get();

      final habitIds = habitRows.map((row) => row.id).toList();
      final logsByHabit = await _loadLogsByHabitIds(
        habitIds,
        maxPerHabit: _startupLogsLimitPerHabit,
      );

      return habitRows
          .map((row) => _rowToEntity(row, logsByHabit[row.id] ?? []))
          .toList();
    } catch (e, st) {
      AppLogger.e(
        '[LOCAL_DS] getHabitsByUserIdPaginated - Error: ${e.runtimeType}',
        error: e,
        stackTrace: st,
      );
      throw CacheException('Error al obtener hábitos: ${e.toString()}');
    }
  }

  @override
  Future<String?> createHabit(HabitEntity habit) async {
    try {
      final habitId = habit.id.isNotEmpty ? habit.id : const Uuid().v4();
      final now = DateTime.now().toIso8601String();

      await _db.into(_db.habitsTable).insertOnConflictUpdate(
            HabitsTableCompanion(
              id: Value(habitId),
              userId: Value(habit.userId),
              title: Value(habit.title),
              description: Value(habit.description),
              icon: Value(habit.icon),
              category: Value(HabitCategoryModel.toStringValue(habit.category)),
              trackingType: Value(
                HabitTrackingTypeModel.toStringValue(habit.trackingType),
              ),
              targetValue: Value(habit.targetValue),
              initialDate: Value(habit.initialDate),
              createdAt: Value(now),
              synced: const Value(0),
              updatedAt: Value(now),
            ),
          );

      return habitId;
    } catch (e, st) {
      AppLogger.e('[LOCAL_DS] createHabit - Error', error: e, stackTrace: st);
      throw CacheException('Error al crear hábito: ${e.toString()}');
    }
  }

  @override
  Future<void> updateHabit(HabitEntity habit) async {
    try {
      await (_db.update(_db.habitsTable)..where((t) => t.id.equals(habit.id)))
          .write(
        HabitsTableCompanion(
          title: Value(habit.title),
          description: Value(habit.description),
          icon: Value(habit.icon),
          category: Value(HabitCategoryModel.toStringValue(habit.category)),
          trackingType: Value(
            HabitTrackingTypeModel.toStringValue(habit.trackingType),
          ),
          targetValue: Value(habit.targetValue),
          synced: const Value(0),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
      );
    } catch (e) {
      throw CacheException('Error al actualizar hábito: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    try {
      await (_db.delete(_db.habitsTable)..where((t) => t.id.equals(habitId)))
          .go();
    } catch (e) {
      throw CacheException('Error al eliminar hábito: ${e.toString()}');
    }
  }

  @override
  Future<String?> createHabitLog(HabitLog habitLog) async {
    try {
      final existing = await (_db.select(_db.habitLogsTable)
            ..where(
              (t) =>
                  t.habitId.equals(habitLog.habitId) &
                  t.date.equals(habitLog.date),
            )
            ..limit(1))
          .getSingleOrNull();

      if (existing != null) {
        AppLogger.w(
          '[LOCAL_DS] Ya existe log para ${habitLog.habitId} en ${habitLog.date}',
        );
        return existing.id;
      }

      final logId = habitLog.id.isNotEmpty ? habitLog.id : const Uuid().v4();

      await _db.into(_db.habitLogsTable).insert(
            HabitLogsTableCompanion(
              id: Value(logId),
              habitId: Value(habitLog.habitId),
              date: Value(habitLog.date),
              value: Value(habitLog.value),
              synced: const Value(0),
            ),
          );

      return logId;
    } catch (e) {
      throw CacheException('Error al crear log: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHabitLogs(String habitId) async {
    try {
      await (_db.delete(_db.habitLogsTable)
            ..where((t) => t.habitId.equals(habitId)))
          .go();
    } catch (e) {
      throw CacheException('Error al eliminar logs del hábito: ${e.toString()}');
    }
  }

  @override
  Future<void> updateHabitLogValue({
    required String habitId,
    required String logId,
    required int value,
  }) async {
    try {
      await (_db.update(_db.habitLogsTable)
            ..where((t) => t.habitId.equals(habitId) & t.id.equals(logId)))
          .write(
        HabitLogsTableCompanion(
          value: Value(value),
          synced: const Value(0),
        ),
      );
    } catch (e) {
      throw CacheException('Error al actualizar log: ${e.toString()}');
    }
  }

  @override
  Future<HabitLog?> getHabitLogById(String logId) async {
    try {
      final row = await (_db.select(_db.habitLogsTable)
            ..where((t) => t.id.equals(logId)))
          .getSingleOrNull();

      if (row == null) return null;

      return HabitLog(
        id: row.id,
        habitId: row.habitId,
        date: row.date,
        value: row.value,
      );
    } catch (e) {
      throw CacheException('Error al obtener log: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHabitPendingSync(String habitId) async {
    try {
      await (_db.delete(_db.pendingSyncTable)
            ..where(
              (t) =>
                  (t.entityType.equals('habit') & t.entityId.equals(habitId)) |
                  (t.entityType.equals('log') &
                      t.data.like('%"habit_id":"$habitId"%')),
            ))
          .go();

      AppLogger.d(
        '[LOCAL_DS] Tareas pendientes eliminadas para hábito: $habitId',
      );
    } catch (e) {
      throw CacheException(
        'Error al eliminar sincronización pendiente: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearAllHabits(String userId) async {
    try {
      await (_db.delete(_db.habitsTable)..where((t) => t.userId.equals(userId)))
          .go();
    } catch (e) {
      throw CacheException('Error al limpiar hábitos: ${e.toString()}');
    }
  }

  @override
  Future<void> saveHabits(List<HabitEntity> habits) async {
    try {
      final now = DateTime.now().toIso8601String();

      await _db.transaction(() async {
        for (final habit in habits) {
          await _db.into(_db.habitsTable).insertOnConflictUpdate(
                HabitsTableCompanion(
                  id: Value(habit.id),
                  userId: Value(habit.userId),
                  title: Value(habit.title),
                  description: Value(habit.description),
                  icon: Value(habit.icon),
                  category: Value(
                    HabitCategoryModel.toStringValue(habit.category),
                  ),
                  trackingType: Value(
                    HabitTrackingTypeModel.toStringValue(habit.trackingType),
                  ),
                  targetValue: Value(habit.targetValue),
                  initialDate: Value(habit.initialDate),
                  createdAt: Value(now),
                  synced: const Value(1),
                  updatedAt: Value(now),
                ),
              );

          for (final log in habit.logs) {
            await _db.into(_db.habitLogsTable).insertOnConflictUpdate(
                  HabitLogsTableCompanion(
                    id: Value(log.id),
                    habitId: Value(log.habitId),
                    date: Value(log.date),
                    value: Value(log.value),
                    synced: const Value(1),
                  ),
                );
          }
        }
      });
    } catch (e) {
      throw CacheException('Error al guardar hábitos: ${e.toString()}');
    }
  }
}

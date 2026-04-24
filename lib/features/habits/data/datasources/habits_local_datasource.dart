import 'package:drift/drift.dart';
import 'package:find_your_mind/core/database/app_database.dart';
import 'package:find_your_mind/core/error/exceptions.dart';
import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:find_your_mind/features/habits/data/models/type_habit_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:uuid/uuid.dart';

abstract class HabitsLocalDatasource {
  // Users Habits
  Future<List<HabitEntity>> getHabitsByUserId(String userId);

  Future<List<HabitEntity>> getHabitsByUserIdPaginated({
    required String userId,
    int limit = 10,
    int offset = 0,
  });

  // Habits
  Future<String?> createHabit(HabitEntity habit);

  Future<void> updateHabit(HabitEntity habit);

  Future<void> deleteHabit(String habitId);

  // Habit Progress
  Future<String?> createHabitProgress(HabitProgress habitProgress);

  Future<void> deleteHabitProgress(String habitId);

  Future<void> updateHabitCounter({
    required String habitId,
    required String progressId,
    required int newCounter,
  });

  Future<HabitProgress?> getHabitProgressById(String progressId);

  // Métodos auxiliares para sincronización
  Future<void> deleteHabitPendingSync(String habitId);

  Future<void> clearAllHabits(String userId);

  Future<void> saveHabits(List<HabitEntity> habits);
}

class HabitsLocalDatasourceImpl implements HabitsLocalDatasource {
  final AppDatabase _db;
  static const int _startupProgressLimitPerHabit = 30;

  HabitsLocalDatasourceImpl({required AppDatabase databaseHelper})
      : _db = databaseHelper;

  Future<Map<String, List<HabitProgressTableData>>> _loadProgressByHabitIds(
    List<String> habitIds, {
    int? maxPerHabit,
  }) async {
    if (habitIds.isEmpty) return {};

    final rows = await (_db.select(_db.habitProgressTable)
          ..where((t) => t.habitId.isIn(habitIds))
          ..orderBy([
            (t) => OrderingTerm.asc(t.habitId),
            (t) => OrderingTerm.desc(t.date),
          ]))
        .get();

    final Map<String, List<HabitProgressTableData>> grouped = {};
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
    List<HabitProgressTableData> progress,
  ) {
    return HabitEntity(
      id: row.id,
      userId: row.userId,
      title: row.title,
      description: row.description,
      icon: row.icon,
      type: TypeHabitModel.fromString(row.type),
      dailyGoal: row.dailyGoal,
      initialDate: row.initialDate,
      progress: progress
          .map(
            (p) => HabitProgress(
              id: p.id,
              habitId: p.habitId,
              date: p.date,
              dailyGoal: p.dailyGoal,
              dailyCounter: p.dailyCounter,
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

      AppLogger.d(
        '[LOCAL_DS] getHabitsByUserId - ${habitRows.length} hábitos encontrados',
      );

      final habitIds = habitRows.map((r) => r.id).toList();
      final progressByHabit = await _loadProgressByHabitIds(habitIds);

      return habitRows
          .map((r) => _rowToEntity(r, progressByHabit[r.id] ?? []))
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

      AppLogger.d(
        '[LOCAL_DS] ${habitRows.length} hábitos encontrados',
      );

      final habitIds = habitRows.map((r) => r.id).toList();
      final progressByHabit = await _loadProgressByHabitIds(
        habitIds,
        maxPerHabit: _startupProgressLimitPerHabit,
      );

      return habitRows
          .map((r) => _rowToEntity(r, progressByHabit[r.id] ?? []))
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
              type: Value(habit.type.name),
              dailyGoal: Value(habit.dailyGoal),
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
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      await _db.transaction(() async {
        await (_db.update(_db.habitsTable)
              ..where((t) => t.id.equals(habit.id)))
            .write(
          HabitsTableCompanion(
            title: Value(habit.title),
            description: Value(habit.description),
            icon: Value(habit.icon),
            type: Value(habit.type.name),
            dailyGoal: Value(habit.dailyGoal),
            synced: const Value(0),
            updatedAt: Value(DateTime.now().toIso8601String()),
          ),
        );

        final updatedCount = await (_db.update(_db.habitProgressTable)
              ..where(
                (t) =>
                    t.habitId.equals(habit.id) &
                    t.date.isBiggerOrEqualValue(todayString),
              ))
            .write(
          HabitProgressTableCompanion(
            dailyGoal: Value(habit.dailyGoal),
            synced: const Value(0),
          ),
        );

        AppLogger.d(
          '[LOCAL_DS] Hábito actualizado: ${habit.id} — '
          'daily_goal sincronizado en $updatedCount registros desde $todayString',
        );
      });
    } catch (e) {
      throw CacheException('Error al actualizar hábito: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    try {
      await (_db.delete(_db.habitsTable)
            ..where((t) => t.id.equals(habitId)))
          .go();
    } catch (e) {
      throw CacheException('Error al eliminar hábito: ${e.toString()}');
    }
  }

  @override
  Future<String?> createHabitProgress(HabitProgress habitProgress) async {
    try {
      final existing = await (_db.select(_db.habitProgressTable)
            ..where(
              (t) =>
                  t.habitId.equals(habitProgress.habitId) &
                  t.date.equals(habitProgress.date),
            )
            ..limit(1))
          .getSingleOrNull();

      if (existing != null) {
        AppLogger.w(
          '[LOCAL_DS] Ya existe progreso para ${habitProgress.habitId} '
          'en ${habitProgress.date} — Retornando ID: ${existing.id}',
        );
        return existing.id;
      }

      final progressId =
          habitProgress.id.isNotEmpty ? habitProgress.id : const Uuid().v4();

      await _db.into(_db.habitProgressTable).insert(
            HabitProgressTableCompanion(
              id: Value(progressId),
              habitId: Value(habitProgress.habitId),
              date: Value(habitProgress.date),
              dailyCounter: Value(habitProgress.dailyCounter),
              dailyGoal: Value(habitProgress.dailyGoal),
              synced: const Value(0),
            ),
          );

      AppLogger.d(
        '[LOCAL_DS] Nuevo progreso creado: $progressId para ${habitProgress.date}',
      );
      return progressId;
    } catch (e) {
      throw CacheException('Error al crear progreso: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHabitProgress(String habitId) async {
    try {
      await (_db.delete(_db.habitProgressTable)
            ..where((t) => t.habitId.equals(habitId)))
          .go();
    } catch (e) {
      throw CacheException(
        'Error al eliminar progresos del hábito: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> updateHabitCounter({
    required String habitId,
    required String progressId,
    required int newCounter,
  }) async {
    try {
      await (_db.update(_db.habitProgressTable)
            ..where(
              (t) => t.habitId.equals(habitId) & t.id.equals(progressId),
            ))
          .write(
        HabitProgressTableCompanion(
          dailyCounter: Value(newCounter),
          synced: const Value(0),
        ),
      );
    } catch (e) {
      throw CacheException('Error al actualizar progreso: ${e.toString()}');
    }
  }

  @override
  Future<HabitProgress?> getHabitProgressById(String progressId) async {
    try {
      final row = await (_db.select(_db.habitProgressTable)
            ..where((t) => t.id.equals(progressId)))
          .getSingleOrNull();

      if (row == null) return null;

      return HabitProgress(
        id: row.id,
        habitId: row.habitId,
        date: row.date,
        dailyGoal: row.dailyGoal,
        dailyCounter: row.dailyCounter,
      );
    } catch (e) {
      throw CacheException('Error al obtener progreso: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteHabitPendingSync(String habitId) async {
    try {
      await (_db.delete(_db.pendingSyncTable)
            ..where(
              (t) =>
                  (t.entityType.equals('habit') & t.entityId.equals(habitId)) |
                  (t.entityType.equals('progress') &
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
      await (_db.delete(_db.habitsTable)
            ..where((t) => t.userId.equals(userId)))
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
                  type: Value(habit.type.name),
                  dailyGoal: Value(habit.dailyGoal),
                  initialDate: Value(habit.initialDate),
                  createdAt: Value(now),
                  synced: const Value(1),
                  updatedAt: Value(now),
                ),
              );

          for (final progress in habit.progress) {
            await _db.into(_db.habitProgressTable).insertOnConflictUpdate(
                  HabitProgressTableCompanion(
                    id: Value(progress.id),
                    habitId: Value(progress.habitId),
                    date: Value(progress.date),
                    dailyGoal: Value(progress.dailyGoal),
                    dailyCounter: Value(progress.dailyCounter),
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

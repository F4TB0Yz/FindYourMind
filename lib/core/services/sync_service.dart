import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:find_your_mind/core/database/app_database.dart';
import 'package:find_your_mind/core/error/exceptions.dart';
import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:find_your_mind/core/utils/map_utils.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/features/habits/data/models/item_habit_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';

class SyncService {
  final AppDatabase _db;
  final HabitsRemoteDataSource _remoteDataSource;

  static const int maxRetryCount = 5;

  SyncService({
    required AppDatabase dbHelper,
    required HabitsRemoteDataSource remoteDataSource,
  }) : _db = dbHelper,
       _remoteDataSource = remoteDataSource;

  Future<void> markPendingSync({
    required String entityType,
    required String entityId,
    required String action,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.into(_db.pendingSyncTable).insertOnConflictUpdate(
            PendingSyncTableCompanion(
              entityType: Value(entityType),
              entityId: Value(entityId),
              actionType: Value(action),
              data: Value(jsonEncode(data)),
              createdAt: Value(DateTime.now().toIso8601String()),
              retryCount: const Value(0),
            ),
          );
    } catch (e) {
      throw CacheException(
        'Error al marcar para sincronización: ${e.toString()}',
      );
    }
  }

  Future<SyncResult> syncPendingChanges() async {
    try {
      final pendingItems = await (_db.select(_db.pendingSyncTable)
            ..where((t) => t.retryCount.isSmallerThanValue(maxRetryCount))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

      final Set<String> failedHabitIds = {};
      int successCount = 0;
      int failureCount = 0;
      final List<String> errors = [];

      for (final item in pendingItems) {
        final entityType = item.entityType;
        final entityId = item.entityId;
        final associatedHabitId = _resolveHabitId(
          entityType: entityType,
          entityId: entityId,
          rawData: item.data,
        );

        if (associatedHabitId.isNotEmpty &&
            failedHabitIds.contains(associatedHabitId)) {
          await (_db.update(_db.pendingSyncTable)
                ..where((t) => t.id.equals(item.id)))
              .write(
            PendingSyncTableCompanion(
              retryCount: Value(item.retryCount + 1),
            ),
          );
          failureCount++;
          continue;
        }

        try {
          final success = await _processSyncItem(item);

          if (success) {
            await (_db.delete(_db.pendingSyncTable)
                  ..where((t) => t.id.equals(item.id)))
                .go();
            await _markAsSynced(entityType, entityId);
            successCount++;
          } else {
            if (entityType == 'habit') {
              failedHabitIds.add(associatedHabitId);
            }
            await (_db.update(_db.pendingSyncTable)
                  ..where((t) => t.id.equals(item.id)))
                .write(
              PendingSyncTableCompanion(
                retryCount: Value(item.retryCount + 1),
              ),
            );
            failureCount++;
          }
        } catch (e) {
          errors.add('$entityType:$entityId — ${e.toString()}');
          if (entityType == 'habit') {
            failedHabitIds.add(associatedHabitId);
          }
          await (_db.update(_db.pendingSyncTable)
                ..where((t) => t.id.equals(item.id)))
              .write(
            PendingSyncTableCompanion(
              retryCount: Value(item.retryCount + 1),
            ),
          );
          failureCount++;
        }
      }

      return SyncResult(
        success: successCount,
        failed: failureCount,
        errors: errors,
      );
    } catch (e) {
      throw CacheException('Error al sincronizar: ${e.toString()}');
    }
  }

  // Backward-compat: _markAsSynced is no longer required (synced column removed).
  Future<void> _markAsSynced(String entityType, String entityId) async {
    // no-op
  }

  String _resolveHabitId({
    required String entityType,
    required String entityId,
    required String rawData,
  }) {
    if (entityType == 'habit') return entityId;
    try {
      final decoded = MapUtils.convertToMap(jsonDecode(rawData));
      return (decoded['habit_id'] as String?) ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<bool> _processSyncItem(PendingSyncTableData item) async {
    final data = MapUtils.convertToMap(jsonDecode(item.data));

    try {
      switch (item.entityType) {
        case 'habit':
          return _syncHabit(item.actionType, data);
        case 'log':
          return _syncLog(item.actionType, data);
        default:
          return false;
      }
    } catch (_) {
      return false;
    }
  }

  Future<bool> _syncHabit(String action, Map<String, dynamic> data) async {
    try {
      switch (action) {
        case 'create':
          final habit = ItemHabitModel.fromJson(data).toEntity();
          final remoteId = await _remoteDataSource.createHabit(habit);
          return remoteId != null;
        case 'update':
          final habit = ItemHabitModel.fromJson(data).toEntity();
          await _remoteDataSource.updateHabit(habit);
          return true;
        case 'delete':
          await _remoteDataSource.deleteHabit(data['id'] as String);
          return true;
        default:
          return false;
      }
    } on ServerException {
      return false;
    } on NetworkException {
      return false;
    } catch (e) {
      AppLogger.e('[SYNC] Error sincronizando hábito', error: e);
      return false;
    }
  }

  Future<bool> _syncLog(String action, Map<String, dynamic> data) async {
    try {
      switch (action) {
        case 'create':
          final log = HabitLog(
            id: data['id'] as String,
            habitId: data['habit_id'] as String,
            date: data['date'] as String,
            value: data['value'] as int,
          );
          final remoteId = await _remoteDataSource.createHabitLog(log);
          return remoteId != null;
        case 'update':
          await _remoteDataSource.updateHabitLogValue(
            habitId: data['habit_id'] as String,
            logId: data['id'] as String,
            value: data['value'] as int,
          );
          return true;
        default:
          return false;
      }
    } on ServerException {
      return false;
    } on NetworkException {
      return false;
    } catch (_) {
      return false;
    }
  }

  // Removed: _markAsSynced column no longer exists (synced dropped).

  Future<int> getPendingCount() async {
    try {
      final count = countAll();
      final result = await (_db.selectOnly(_db.pendingSyncTable)
            ..addColumns([count]))
          .getSingle();
      return result.read(count) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> clearPendingSync() async {
    try {
      await _db.delete(_db.pendingSyncTable).go();
    } catch (e) {
      throw CacheException(
        'Error al limpiar cola de sincronización: ${e.toString()}',
      );
    }
  }

  Future<List<PendingSyncTableData>> getFailedItems() async {
    try {
      return await (_db.select(_db.pendingSyncTable)
            ..where((t) => t.retryCount.isBiggerOrEqualValue(maxRetryCount)))
          .get();
    } catch (_) {
      return [];
    }
  }

  Future<void> purgeFailedItems() async {
    try {
      await (_db.delete(_db.pendingSyncTable)
            ..where((t) => t.retryCount.isBiggerOrEqualValue(maxRetryCount)))
          .go();
    } catch (e) {
      throw CacheException(
        'Error al purgar items fallidos: ${e.toString()}',
      );
    }
  }
}

class SyncResult {
  final int success;
  final int failed;
  final List<String> errors;

  SyncResult({
    required this.success,
    required this.failed,
    required this.errors,
  });

  bool get hasErrors => failed > 0;
  bool get isFullSuccess => failed == 0 && success > 0;

  @override
  String toString() {
    return 'SyncResult(success: $success, failed: $failed, errors: ${errors.length})';
  }
}

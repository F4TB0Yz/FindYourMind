import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:find_your_mind/core/database/app_database.dart';
import 'package:find_your_mind/core/error/exceptions.dart';
import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:find_your_mind/core/utils/map_utils.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/features/habits/data/models/item_habit_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';

/// Servicio encargado de sincronizar cambios locales con el servidor remoto
class SyncService {
  final AppDatabase _db;
  final HabitsRemoteDataSource _remoteDataSource;

  SyncService({
    required AppDatabase dbHelper,
    required HabitsRemoteDataSource remoteDataSource,
  })  : _db = dbHelper,
        _remoteDataSource = remoteDataSource;

  /// Marca una operación como pendiente de sincronización
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

  /// Sincroniza todos los cambios pendientes con el servidor.
  ///
  /// Implementa **FIFO estricto con Bloqueo en Cascada** (Dependency Awareness):
  /// - Procesa los ítems en orden exacto de `created_at ASC` (una sola cola).
  /// - Si la sincronización de un `habit` falla, todos sus `progress` dependientes
  ///   se marcan automáticamente para reintento sin hacer llamadas a la red,
  ///   previniendo violaciones de FK en Supabase.
  Future<SyncResult> syncPendingChanges() async {
    try {
      final pendingItems = await (_db.select(_db.pendingSyncTable)
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

      final Set<String> failedHabitIds = {};
      int successCount = 0;
      int failureCount = 0;
      final List<String> errors = [];

      for (final item in pendingItems) {
        final entityType = item.entityType;
        final entityId = item.entityId;

        final String associatedHabitId = _resolveHabitId(
          entityType: entityType,
          entityId: entityId,
          rawData: item.data,
        );

        if (associatedHabitId.isNotEmpty &&
            failedHabitIds.contains(associatedHabitId)) {
          AppLogger.w(
            '[SYNC] Bloqueando $entityType:$entityId — '
            'su hábito padre ($associatedHabitId) falló en este ciclo',
          );
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
          final bool success = await _processSyncItem(item);

          if (success) {
            await (_db.delete(_db.pendingSyncTable)
                  ..where((t) => t.id.equals(item.id)))
                .go();
            await _markAsSynced(entityType, entityId);
            successCount++;
            AppLogger.d('[SYNC] ✅ $entityType:$entityId sincronizado');
          } else {
            if (entityType == 'habit') {
              failedHabitIds.add(associatedHabitId);
              AppLogger.w(
                '[SYNC] ❌ Hábito $entityId falló — bloqueando dependientes',
              );
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
          failureCount++;
        }
      }

      AppLogger.d(
        '[SYNC] Ciclo completado — '
        'OK: $successCount | FAIL: $failureCount | CASCADE-BLOCKED: ${failedHabitIds.length} hábitos',
      );

      return SyncResult(
        success: successCount,
        failed: failureCount,
        errors: errors,
      );
    } catch (e) {
      throw CacheException('Error al sincronizar: ${e.toString()}');
    }
  }

  String _resolveHabitId({
    required String entityType,
    required String entityId,
    required String rawData,
  }) {
    if (entityType == 'habit') return entityId;
    try {
      final Map<String, dynamic> decoded = MapUtils.convertToMap(
        jsonDecode(rawData),
      );
      return (decoded['habit_id'] as String?) ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<bool> _processSyncItem(PendingSyncTableData item) async {
    final decodedData = jsonDecode(item.data);
    final data = MapUtils.convertToMap(decodedData);

    try {
      switch (item.entityType) {
        case 'habit':
          return await _syncHabit(item.actionType, data);
        case 'progress':
          return await _syncProgress(item.actionType, data);
        default:
          return false;
      }
    } catch (e) {
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
          await _remoteDataSource.deleteHabit(data['id']);
          return true;

        default:
          return false;
      }
    } on ServerException {
      return false;
    } on NetworkException {
      return false;
    } catch (e) {
      AppLogger.e('[SYNC] Error inesperado al sincronizar hábito', error: e);
      return false;
    }
  }

  Future<bool> _syncProgress(String action, Map<String, dynamic> data) async {
    try {
      switch (action) {
        case 'create':
          final progress = HabitProgress(
            id: data['id'],
            habitId: data['habit_id'],
            date: data['date'],
            dailyGoal: data['daily_goal'],
            dailyCounter: data['daily_counter'],
          );
          final remoteId = await _remoteDataSource.createHabitProgress(
            progress,
          );
          return remoteId != null;

        case 'update':
          await _remoteDataSource.updateHabitCounter(
            habitId: data['habit_id'],
            progressId: data['id'],
            newCounter: data['daily_counter'],
          );
          return true;

        default:
          return false;
      }
    } on ServerException {
      return false;
    } on NetworkException {
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _markAsSynced(String entityType, String entityId) async {
    if (entityType == 'habit') {
      await (_db.update(_db.habitsTable)
            ..where((t) => t.id.equals(entityId)))
          .write(
        HabitsTableCompanion(
          synced: const Value(1),
          updatedAt: Value(DateTime.now().toIso8601String()),
        ),
      );
    } else if (entityType == 'progress') {
      await (_db.update(_db.habitProgressTable)
            ..where((t) => t.id.equals(entityId)))
          .write(const HabitProgressTableCompanion(synced: Value(1)));
    }
  }

  /// Obtiene el número de elementos pendientes de sincronización
  Future<int> getPendingCount() async {
    try {
      final count = countAll();
      final result = await (_db.selectOnly(_db.pendingSyncTable)
            ..addColumns([count]))
          .getSingle();
      return result.read(count) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Limpia la cola de sincronización (usar con precaución)
  Future<void> clearPendingSync() async {
    try {
      await _db.delete(_db.pendingSyncTable).go();
    } catch (e) {
      throw CacheException(
        'Error al limpiar cola de sincronización: ${e.toString()}',
      );
    }
  }
}

/// Resultado de una operación de sincronización
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

import 'dart:convert';
import 'package:find_your_mind/core/config/database_helper.dart';
import 'package:find_your_mind/core/error/exceptions.dart';
import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:find_your_mind/core/utils/map_utils.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/features/habits/data/models/item_habit_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:sqflite/sqflite.dart';

/// Servicio encargado de sincronizar cambios locales con el servidor remoto
class SyncService {
  final DatabaseHelper _dbHelper;
  final HabitsRemoteDataSource _remoteDataSource;

  SyncService({
    required DatabaseHelper dbHelper,
    required HabitsRemoteDataSource remoteDataSource,
  }) : _dbHelper = dbHelper,
       _remoteDataSource = remoteDataSource;

  /// Marca una operación como pendiente de sincronización
  Future<void> markPendingSync({
    required String entityType,
    required String entityId,
    required String action,
    required Map<String, dynamic> data,
  }) async {
    try {
      final db = await _dbHelper.database;

      await db.insert('pending_sync', {
        'entity_type': entityType,
        'entity_id': entityId,
        'action': action,
        'data': jsonEncode(data),
        'created_at': DateTime.now().toIso8601String(),
        'retry_count': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } on DatabaseException catch (e) {
      throw CacheException(
        'Error al marcar para sincronización: ${e.toString()}',
      );
    }
  }

  /// Sincroniza todos los cambios pendientes con el servidor.
  ///
  /// Implementa **FIFO estricto con Bloqueo en Cascada** (Dependency Awareness):
  /// - Procesa los ítems en el orden exacto de `created_at ASC` (una sola cola).
  /// - Si la sincronización de un `habit` falla, todos sus `progress` dependientes
  ///   se marcan automáticamente para reintento sin hacer llamadas a la red,
  ///   previniendo violaciones de FK en Supabase (progreso sin padre).
  Future<SyncResult> syncPendingChanges() async {
    try {
      final db = await _dbHelper.database;

      final pendingItemsRaw = await db.query(
        'pending_sync',
        orderBy: 'created_at ASC',
      );

      // Cola FIFO única — sin separación de tipos
      final pendingItems = pendingItemsRaw
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      // 🔒 Registro de hábitos que fallaron en este ciclo.
      // Cualquier progreso que dependa de uno de estos IDs será bloqueado en cascada.
      final Set<String> failedHabitIds = {};

      int successCount = 0;
      int failureCount = 0;
      final List<String> errors = [];

      for (final item in pendingItems) {
        final entityType = item['entity_type'] as String;
        final entityId = item['entity_id'] as String;

        // 1. Resolver el habit_id asociado a este ítem para el bloqueo en cascada
        // Usamos un helper privado para mantener la declaración como final
        final String associatedHabitId = _resolveHabitId(
          entityType: entityType,
          entityId: entityId,
          rawData: item['data'] as String? ?? '',
        );

        // 2. Bloqueo en Cascada: si el hábito padre ya falló, bloquear este ítem
        if (associatedHabitId.isNotEmpty &&
            failedHabitIds.contains(associatedHabitId)) {
          AppLogger.w(
            '[SYNC] Bloqueando $entityType:$entityId — '
            'su hábito padre ($associatedHabitId) falló en este ciclo',
          );
          await db.update(
            'pending_sync',
            {'retry_count': (item['retry_count'] as int) + 1},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
          failureCount++;
          continue;
        }

        // 3. Intentar sincronizar con el servidor
        try {
          final bool success = await _processSyncItem(item);

          if (success) {
            await db.delete(
              'pending_sync',
              where: 'id = ?',
              whereArgs: [item['id']],
            );
            await _markAsSynced(db, entityType, entityId);
            successCount++;
            AppLogger.d('[SYNC] ✅ $entityType:$entityId sincronizado');
          } else {
            // Fallo de red/servidor → registrar para bloqueo en cascada
            if (entityType == 'habit') {
              failedHabitIds.add(associatedHabitId);
              AppLogger.w(
                '[SYNC] ❌ Hábito $entityId falló — bloqueando dependientes',
              );
            }
            await db.update(
              'pending_sync',
              {'retry_count': (item['retry_count'] as int) + 1},
              where: 'id = ?',
              whereArgs: [item['id']],
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
    } on DatabaseException catch (e) {
      throw CacheException('Error al sincronizar: ${e.toString()}');
    }
  }

  /// Resuelve el `habit_id` asociado a un ítem de la cola de sincronización.
  ///
  /// - Para ítems de tipo `habit`, el `habit_id` ES el propio `entity_id`.
  /// - Para ítems de tipo `progress`, el `habit_id` se extrae del JSON en `data`.
  ///
  /// Retorna una cadena vacía si no puede resolver el ID (ej. JSON inválido).
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

  /// Procesa un item individual de la cola de sincronización
  Future<bool> _processSyncItem(Map<String, dynamic> item) async {
    final entityType = item['entity_type'] as String;
    final action = item['action'] as String;

    // Decodificar JSON y convertir explícitamente a Map<String, dynamic>
    final decodedData = jsonDecode(item['data'] as String);
    final data = MapUtils.convertToMap(decodedData);

    try {
      switch (entityType) {
        case 'habit':
          return await _syncHabit(action, data);
        case 'progress':
          return await _syncProgress(action, data);
        default:
          return false;
      }
    } catch (e) {
      // Si falla, retornar false para reintentar después
      return false;
    }
  }

  /// Sincroniza un hábito con el servidor
  Future<bool> _syncHabit(String action, Map<String, dynamic> data) async {
    try {
      switch (action) {
        case 'create':
          final habitModel = ItemHabitModel.fromJson(data);
          final habit = habitModel.toEntity();
          final remoteId = await _remoteDataSource.createHabit(habit);

          if (remoteId == null) return false;

          // ✅ Con UUIDs únicos, remoteId debería ser igual a data['id']
          // No es necesario actualizar nada

          return true;

        case 'update':
          final habitModel = ItemHabitModel.fromJson(data);
          final habit = habitModel.toEntity();
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

  /// Sincroniza un progreso de hábito con el servidor
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

          if (remoteId == null) return false;

          // ✅ Con UUIDs únicos, remoteId debería ser igual a data['id']
          // No es necesario actualizar nada

          return true;

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

  /// Marca una entidad como sincronizada
  Future<void> _markAsSynced(
    Database db,
    String entityType,
    String entityId,
  ) async {
    String table;

    switch (entityType) {
      case 'habit':
        table = 'habits';
        break;
      case 'progress':
        table = 'habit_progress';
        break;
      default:
        return;
    }

    await db.update(
      table,
      {
        'synced': 1,
        if (entityType == 'habit')
          'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [entityId],
    );
  }

  /// Obtiene el número de elementos pendientes de sincronización
  Future<int> getPendingCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM pending_sync',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Limpia la cola de sincronización (usar con precaución)
  Future<void> clearPendingSync() async {
    try {
      final db = await _dbHelper.database;
      await db.delete('pending_sync');
    } on DatabaseException catch (e) {
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

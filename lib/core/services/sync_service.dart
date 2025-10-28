import 'dart:convert';
import 'package:find_your_mind/core/config/database_helper.dart';
import 'package:find_your_mind/core/error/exceptions.dart';
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
  })  : _dbHelper = dbHelper,
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

      await db.insert(
        'pending_sync',
        {
          'entity_type': entityType,
          'entity_id': entityId,
          'action': action,
          'data': jsonEncode(data),
          'created_at': DateTime.now().toIso8601String(),
          'retry_count': 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } on DatabaseException catch (e) {
      throw CacheException('Error al marcar para sincronización: ${e.toString()}');
    }
  }

  /// Sincroniza todos los cambios pendientes con el servidor
  Future<SyncResult> syncPendingChanges() async {
    try {
      final db = await _dbHelper.database;
      
      final pendingItemsRaw = await db.query(
        'pending_sync',
        orderBy: 'created_at ASC',
      );

      // Convertir explícitamente a List<Map<String, dynamic>>
      final pendingItems = pendingItemsRaw
          .map((item) => Map<String, dynamic>.from(item))
          .toList();

      // Separar hábitos y progresos para sincronizar en orden
      final habitItems = pendingItems.where((item) => item['entity_type'] == 'habit').toList();
      final progressItems = pendingItems.where((item) => item['entity_type'] == 'progress').toList();
      
      // Primero sincronizar todos los hábitos
      final habitResults = await _syncItems(db, habitItems);
      
      // Luego sincronizar los progresos
      final progressResults = await _syncItems(db, progressItems);

  
      return SyncResult(
        success: habitResults.success + progressResults.success,
        failed: habitResults.failed + progressResults.failed,
        errors: [...habitResults.errors, ...progressResults.errors],
      );
    } on DatabaseException catch (e) {
      throw CacheException('Error al sincronizar: ${e.toString()}');
    }
  }

  Future<SyncResult> _syncItems(Database db, List<Map<String, dynamic>> items) async {
    int successCount = 0;
    int failureCount = 0;
    List<String> errors = [];

    for (var item in items) {
      try {
        final bool success = await _processSyncItem(item);
      
        if (success) {
          // Eliminar de la cola si tuvo éxito
          await db.delete(
            'pending_sync',
            where: 'id = ?',
            whereArgs: [item['id']],
          );
          
          // Marcar como sincronizado en la tabla correspondiente
          await _markAsSynced(
            db,
            item['entity_type'] as String,
            item['entity_id'] as String,
          );
          
          successCount++;
        } else {
          // Incrementar contador de reintentos
          await db.update(
            'pending_sync',
            {'retry_count': (item['retry_count'] as int) + 1},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
          failureCount++;
        } 
      } catch (e) {
        errors.add('${item['entity_type']}: ${e.toString()}');
        failureCount++;
      }
    }

    return SyncResult(
      success: successCount,
      failed: failureCount,
      errors: errors,
    );
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
      print("error al sincronizar hábito: $e");
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
          final remoteId = await _remoteDataSource.createHabitProgress(progress);
          
          if (remoteId == null) return false;

          // ✅ Con UUIDs únicos, remoteId debería ser igual a data['id']
          // No es necesario actualizar nada
          
          return true;

        case 'update':
          await _remoteDataSource.incrementHabitProgress(
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
  Future<void> _markAsSynced(Database db, String entityType, String entityId) async {
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
        if (entityType == 'habit') 'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [entityId],
    );
  }

  /// Obtiene el número de elementos pendientes de sincronización
  Future<int> getPendingCount() async {
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery('SELECT COUNT(*) as count FROM pending_sync');
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
      throw CacheException('Error al limpiar cola de sincronización: ${e.toString()}');
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

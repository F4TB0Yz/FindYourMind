import 'dart:convert';
import 'package:find_your_mind/core/config/database_helper.dart';
import 'package:find_your_mind/core/error/exceptions.dart';
import 'package:find_your_mind/core/utils/map_utils.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/features/habits/data/models/item_habit_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:sqflite/sqflite.dart';

/// Callback para notificar cuando se actualiza el ID de un hábito
typedef OnHabitIdUpdatedCallback = void Function(String oldId, String newId);

/// Servicio encargado de sincronizar cambios locales con el servidor remoto
class SyncService {
  final DatabaseHelper _dbHelper;
  final HabitsRemoteDataSource _remoteDataSource;
  
  /// Callback opcional para notificar cuando se actualiza un ID de hábito
  static OnHabitIdUpdatedCallback? onHabitIdUpdated;

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

          // Actualizar el ID local con el ID remoto si es diferente
          await _updateLocalId('habits', data['id'], remoteId);
          // Actualizar el ID de los progresos asociados
          await _updateProcessIdsForHabit(data, remoteId);

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
          await _remoteDataSource.createHabitProgress(progress);
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

  /// Actualiza el ID local de un hábito con el ID remoto de Supabase
  /// Este método se usa cuando se crea un hábito con conexión y se necesita
  /// actualizar el ID temporal local con el ID real de Supabase
  Future<void> updateLocalHabitId(String localId, String remoteId) async {
    if (localId == remoteId) return;
    
    print('🔄 [SYNC] Actualizando ID local $localId → $remoteId');
    
    final db = await _dbHelper.database;
    
    // Actualizar el ID en la tabla habits Y marcar como sincronizado
    await db.update(
      'habits',
      {
        'id': remoteId,
        'synced': 1, // Marcar como sincronizado
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [localId],
    );
    
    // Actualizar el habit_id en todos los progresos asociados
    await db.update(
      'habit_progress',
      {'habit_id': remoteId},
      where: 'habit_id = ?',
      whereArgs: [localId],
    );
    
    // Actualizar habit_id en pending_sync si existe
    final pendingProgress = await db.query(
      'pending_sync',
      where: 'entity_type = ?',
      whereArgs: ['progress'],
    );

    for (var item in pendingProgress) {
      final progressData = jsonDecode(item['data'] as String) as Map<String, dynamic>;
      
      if (progressData['habit_id'] == localId) {
        progressData['habit_id'] = remoteId;
        
        await db.update(
          'pending_sync',
          {'data': jsonEncode(progressData)},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
    }
    
    print('✅ [SYNC] ID actualizado correctamente en todas las tablas');
    
    // 🔔 Notificar al provider (si está registrado) para actualizar la UI silenciosamente
    onHabitIdUpdated?.call(localId, remoteId);
  }

  /// Actualiza el ID local con el ID remoto
  Future<void> _updateLocalId(String table, String localId, String remoteId) async {
    if (localId == remoteId) return;

    final db = await _dbHelper.database;
    await db.update(
      table,
      {'id': remoteId},
      where: 'id = ?',
      whereArgs: [localId],
    );
  }

  // Actualiza los IDs de los progresos asociados a un hábito
  Future<void> _updateProcessIdsForHabit(Map<String, dynamic> data, String remoteHabitId) async {
    final db = await _dbHelper.database;
    final localHabitId = data['id'];

    // Actualizar habit_id en la tabla habit_progress
    await db.update(
      'habit_progress',
      {'habit_id': remoteHabitId},
      where: 'habit_id = ?',
      whereArgs: [localHabitId],
    );

    // Actualizar habit_id en los datos JSON de pending_sync para progresos
    final pendingProgress = await db.query(
      'pending_sync',
      where: 'entity_type = ?',
      whereArgs: ['progress'],
    );

    for (var item in pendingProgress) {
      final progressData = jsonDecode(item['data'] as String) as Map<String, dynamic>;
      
      if (progressData['habit_id'] == localHabitId) {
        progressData['habit_id'] = remoteHabitId;
        
        await db.update(
          'pending_sync',
          {'data': jsonEncode(progressData)},
          where: 'id = ?',
          whereArgs: [item['id']],
        );
      }
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

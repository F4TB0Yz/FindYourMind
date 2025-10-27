import 'dart:convert';
import 'dart:developer' as developer;
import 'package:find_your_mind/core/config/database_helper.dart';
import 'package:find_your_mind/core/error/exceptions.dart';
import 'package:find_your_mind/core/utils/map_utils.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/features/habits/data/models/item_habit_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
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
  }) : _dbHelper = dbHelper,
       _remoteDataSource = remoteDataSource;

  /// Marca una operación como pendiente de sincronización
  Future<void> markPendingSync({
    required String entityType,
    required String entityId,
    required String action,
    required Map<String, dynamic> data,
  }) async {
    developer.log(
      'Marcando operación pendiente de sincronización',
      name: 'SyncService.markPendingSync',
      error: 'entityType: $entityType, entityId: $entityId, action: $action',
    );
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

      final resultCheck = await db.rawQuery(
        'SELECT COUNT(*) as count FROM pending_sync WHERE entity_type = ? AND entity_id = ? AND action = ? AND data = ?',
        [entityType, entityId, action, jsonEncode(data)],
      );
      final insertedCount = Sqflite.firstIntValue(resultCheck) ?? 0;
      if (insertedCount == 0) {
        developer.log(
          'No se guardó la operación en pending_sync',
          name: 'SyncService.markPendingSync',
        );
        throw CacheException(
          'Error al guardar operación pendiente para sincronización',
        );
      }

      developer.log(
        'Operación marcada exitosamente para sincronización',
        name: 'SyncService.markPendingSync',
      );
    } on DatabaseException catch (e) {
      developer.log(
        'Error al marcar para sincronización',
        name: 'SyncService.markPendingSync',
        error: e,
      );
      throw CacheException(
        'Error al marcar para sincronización: ${e.toString()}',
      );
    }
  }

  /// Sincroniza todos los cambios pendientes con el servidor
  Future<SyncResult> syncPendingChanges(NetworkInfo networkInfo) async {
    developer.log(
      'Iniciando sincronización de cambios pendientes',
      name: 'SyncService.syncPendingChanges',
    );
    if (!await networkInfo.isConnected) {
      developer.log(
        'No hay conexión de red, abortando sincronización',
        name: 'SyncService.syncPendingChanges',
      );
      return SyncResult(
        success: 0,
        failed: 0,
        errors: ['No network connection'],
      );
    }

    try {
      final db = await _dbHelper.database;
      
      final pendingItemsRaw = await db.query(
        'pending_sync',
        orderBy: 'created_at ASC',
      );

      // Comprobar si hay items para sincronizar
      if (pendingItems.isEmpty) {
        developer.log(
          'No hay cambios pendientes para sincronizar',
          name: 'SyncService.syncPendingChanges',
        );
        return SyncResult(success: 0, failed: 0, errors: []);
      }

      developer.log(
        'Items pendientes encontrados: ${pendingItems.length}',
        name: 'SyncService.syncPendingChanges',
      );

      // Separar items por tipo de entidad para procesar en orden correcto
      final habitItems = pendingItems
          .where((item) => item['entity_type'] == 'habit')
          .toList();
      final progressItems = pendingItems
          .where((item) => item['entity_type'] == 'progress')
          .toList();

      developer.log(
        'Hábitos a sincronizar: ${habitItems.length}, Progresos a sincronizar: ${progressItems.length}',
        name: 'SyncService.syncPendingChanges',
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

      final result = SyncResult(
        success: successCount,
        failed: failureCount,
        errors: errors,
      );
      developer.log(
        'Sincronización completada: $result',
        name: 'SyncService.syncPendingChanges',
      );
      return result;
    } on DatabaseException catch (e) {
      developer.log(
        'Error de base de datos al sincronizar',
        name: 'SyncService.syncPendingChanges',
        error: e,
      );
      throw CacheException('Error al sincronizar: ${e.toString()}');
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
          developer.log(
            'Tipo de entidad desconocido: $entityType',
            name: 'SyncService._processSyncItem',
          );
          return false;
      }
    } catch (e) {
      developer.log(
        'Error al procesar item de sincronización',
        name: 'SyncService._processSyncItem',
        error: e,
      );
      // Si falla, retornar false para reintentar después
      return false;
    }
  }

  /// Sincroniza un hábito con el servidor
  Future<bool> _syncHabit(String action, Map<String, dynamic> data) async {
    developer.log(
      'Sincronizando hábito',
      name: 'SyncService._syncHabit',
      error: 'action: $action, habitId: ${data['id']}',
    );
    try {
      switch (action) {
        case 'create':
          developer.log(
            'Creando hábito en servidor',
            name: 'SyncService._syncHabit',
          );

          // Convertir la lista de progress de List<dynamic> a List<Map<String, dynamic>>
          final Map<String, dynamic> habitData = Map<String, dynamic>.from(
            data,
          );
          if (habitData['progress'] != null) {
            habitData['progress'] = (habitData['progress'] as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          } else {
            habitData['progress'] = <Map<String, dynamic>>[];
          }

          final ItemHabitModel habitModel = ItemHabitModel.fromJson(habitData);
          final HabitEntity habit = habitModel.toEntity();
          final remoteId = await _remoteDataSource.createHabit(habit);
          
          if (remoteId == null) return false;

          // Actualizar el ID local con el ID remoto si es diferente
          await _updateLocalId('habits', data['id'], remoteId);
          // Actualizar el ID de los progresos asociados
          await _updateProcessIdsForHabit(data, remoteId);

          return true;

        case 'update':
          developer.log(
            'Actualizando hábito en servidor',
            name: 'SyncService._syncHabit',
          );

          // Convertir la lista de progress de List<dynamic> a List<Map<String, dynamic>>
          final Map<String, dynamic> habitData = Map<String, dynamic>.from(
            data,
          );
          if (habitData['progress'] != null) {
            habitData['progress'] = (habitData['progress'] as List)
                .map((e) => Map<String, dynamic>.from(e as Map))
                .toList();
          } else {
            habitData['progress'] = <Map<String, dynamic>>[];
          }

          final habitModel = ItemHabitModel.fromJson(habitData);
          final habit = habitModel.toEntity();
          await _remoteDataSource.updateHabit(habit);
          developer.log(
            'Hábito actualizado exitosamente',
            name: 'SyncService._syncHabit',
          );
          return true;

        case 'delete':
          developer.log(
            'Eliminando hábito en servidor',
            name: 'SyncService._syncHabit',
          );
          await _remoteDataSource.deleteHabit(data['id']);
          developer.log(
            'Hábito eliminado exitosamente',
            name: 'SyncService._syncHabit',
          );
          return true;

        default:
          developer.log(
            'Acción desconocida para hábito: $action',
            name: 'SyncService._syncHabit',
          );
          return false;
      }
    } on ServerException catch (e) {
      developer.log(
        'Error del servidor al sincronizar hábito',
        name: 'SyncService._syncHabit',
        error: e,
      );
      return false;
    } on NetworkException catch (e) {
      developer.log(
        'Error de red al sincronizar hábito',
        name: 'SyncService._syncHabit',
        error: e,
      );
      return false;
    } catch (e) {
      print("error al sincronizar hábito: $e");
      return false;
    }
  }

  /// Sincroniza un progreso de hábito con el servidor
  Future<bool> _syncProgress(String action, Map<String, dynamic> data) async {
    developer.log(
      'Sincronizando progreso',
      name: 'SyncService._syncProgress',
      error: 'action: $action, progressId: ${data['id']}',
    );
    try {
      switch (action) {
        case 'create':
          developer.log(
            'Creando progreso en servidor',
            name: 'SyncService._syncProgress',
          );
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
          developer.log(
            'Progreso creado exitosamente',
            name: 'SyncService._syncProgress',
          );

          if (remoteId != null) {
            developer.log(
              'Progreso creado con ID remoto: $remoteId',
              name: 'SyncService._syncProgress',
            );
            // Actualizar el ID local con el ID remoto si es diferente
            await _updateLocalId('habit_progress', data['id'], remoteId);
          }

          return true;

        case 'update':
          developer.log(
            'Actualizando progreso en servidor',
            name: 'SyncService._syncProgress',
          );
          await _remoteDataSource.incrementHabitProgress(
            habitId: data['habit_id'],
            progressId: data['id'],
            newCounter: data['daily_counter'],
          );
          developer.log(
            'Progreso actualizado exitosamente',
            name: 'SyncService._syncProgress',
          );
          return true;

        default:
          developer.log(
            'Acción desconocida para progreso: $action',
            name: 'SyncService._syncProgress',
          );
          return false;
      }
    } on ServerException catch (e) {
      developer.log(
        'Error del servidor al sincronizar progreso',
        name: 'SyncService._syncProgress',
        error: e,
      );
      return false;
    } on NetworkException catch (e) {
      developer.log(
        'Error de red al sincronizar progreso',
        name: 'SyncService._syncProgress',
        error: e,
      );
      return false;
    } catch (e) {
      developer.log(
        'Error inesperado al sincronizar progreso',
        name: 'SyncService._syncProgress',
        error: e,
      );
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
  Future<void> _updateLocalId(
    String table,
    String localId,
    String remoteId,
  ) async {
    if (localId == remoteId) {
      developer.log(
        'IDs son iguales, no se requiere actualización',
        name: 'SyncService._updateLocalId',
      );
      return;
    }

    developer.log(
      'Actualizando ID local a ID remoto',
      name: 'SyncService._updateLocalId',
      error: 'table: $table, localId: $localId, remoteId: $remoteId',
    );

    final db = await _dbHelper.database;

    // Actualizar el ID en la tabla principal
    await db.update(
      table,
      {'id': remoteId},
      where: 'id = ?',
      whereArgs: [localId],
    );

    // Si es un hábito, actualizar también las referencias en tablas relacionadas
    if (table == 'habits') {
      developer.log(
        'Actualizando referencias de habit_id en tablas relacionadas',
        name: 'SyncService._updateLocalId',
      );

      // Actualizar habit_id en la tabla habit_progress
      await db.update(
        'habit_progress',
        {'habit_id': remoteId},
        where: 'habit_id = ?',
        whereArgs: [localId],
      );

      // Actualizar habit_id en pending_sync para progresos pendientes
      final pendingProgressItems = await db.query(
        'pending_sync',
        where: 'entity_type = ?',
        whereArgs: ['progress'],
      );

      for (var item in pendingProgressItems) {
        final data = jsonDecode(item['data'] as String) as Map<String, dynamic>;
        if (data['habit_id'] == localId) {
          data['habit_id'] = remoteId;
          await db.update(
            'pending_sync',
            {'data': jsonEncode(data)},
            where: 'id = ?',
            whereArgs: [item['id']],
          );
          developer.log(
            'Actualizado habit_id en pending_sync para progreso: ${data['id']}',
            name: 'SyncService._updateLocalId',
          );
        }
      }
    }

    developer.log(
      'ID actualizado exitosamente',
      name: 'SyncService._updateLocalId',
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
  Future<void> _markAsSynced(
    Database db,
    String entityType,
    String entityId,
  ) async {
    developer.log(
      'Marcando entidad como sincronizada',
      name: 'SyncService._markAsSynced',
      error: 'entityType: $entityType, entityId: $entityId',
    );

    String table;

    switch (entityType) {
      case 'habit':
        table = 'habits';
        break;
      case 'progress':
        table = 'habit_progress';
        break;
      default:
        developer.log(
          'Tipo de entidad desconocido, no se marca como sincronizado',
          name: 'SyncService._markAsSynced',
        );
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

    developer.log(
      'Entidad marcada como sincronizada exitosamente',
      name: 'SyncService._markAsSynced',
    );
  }

  /// Obtiene el número de elementos pendientes de sincronización
  Future<int> getPendingCount() async {
    developer.log(
      'Obteniendo conteo de elementos pendientes',
      name: 'SyncService.getPendingCount',
    );
    try {
      final db = await _dbHelper.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM pending_sync',
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      developer.log(
        'Elementos pendientes: $count',
        name: 'SyncService.getPendingCount',
      );
      return count;
    } catch (e) {
      developer.log(
        'Error al obtener conteo de elementos pendientes',
        name: 'SyncService.getPendingCount',
        error: e,
      );
      return 0;
    }
  }

  /// Limpia la cola de sincronización (usar con precaución)
  Future<void> clearPendingSync() async {
    developer.log(
      'Limpiando cola de sincronización',
      name: 'SyncService.clearPendingSync',
    );
    try {
      final db = await _dbHelper.database;
      await db.delete('pending_sync');
      developer.log(
        'Cola de sincronización limpiada exitosamente',
        name: 'SyncService.clearPendingSync',
      );
    } on DatabaseException catch (e) {
      developer.log(
        'Error al limpiar cola de sincronización',
        name: 'SyncService.clearPendingSync',
        error: e,
      );
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

import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/core/network/network_info.dart';
import 'package:find_your_mind/core/services/sync_service.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_local_datasource.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';

/// Implementación del repositorio de hábitos con estrategia offline-first
/// 1. Siempre lee de SQLite primero (rápido)
/// 2. Sincroniza con Supabase en segundo plano (si hay internet)
/// 3. Guarda cambios locales y marca para sincronización posterior
class HabitRepositoryImpl implements HabitRepository {
  final HabitsRemoteDataSource _remoteDataSource;
  final HabitsLocalDatasource _localDataSource;
  final NetworkInfo _networkInfo;
  final SyncService _syncService;

  HabitRepositoryImpl({
    required HabitsRemoteDataSource remoteDataSource,
    required HabitsLocalDatasource localDataSource,
    required NetworkInfo networkInfo,
    required SyncService syncService,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _networkInfo = networkInfo,
        _syncService = syncService;

  @override
  Future<List<HabitEntity>> getHabitsByEmail(String email) async {
    // 1. Cargar desde SQLite primero (respuesta rápida)
    final localHabits = await _localDataSource.getHabitsByUserId(email);

    // 2. Si SQLite está vacío y hay internet, cargar desde servidor
    if (localHabits.isEmpty && await _networkInfo.isConnected) {
      try {
        final remoteHabits = await _remoteDataSource.getHabitsByUserId(email);
        if (remoteHabits.isNotEmpty) {
          await _localDataSource.saveHabits(remoteHabits);
          return remoteHabits;
        }
      } catch (e) {
        // Si falla la carga remota, devolver lista vacía
        return [];
      }
    }

    // 3. Si ya hay datos locales, sincronizar en segundo plano
    if (localHabits.isNotEmpty && await _networkInfo.isConnected) {
      _syncInBackground(email);
    }

    return localHabits;
  }

  @override
  Future<List<HabitEntity>> getHabitsByEmailPaginated({
    required String email,
    int limit = 10,
    int offset = 0,
  }) async {
    print('🔍 [REPO] getHabitsByEmailPaginated - email: $email, offset: $offset, limit: $limit');
    
    // 1. Cargar desde SQLite primero
    final localHabits = await _localDataSource.getHabitsByUserIdPaginated(
      userId: email,
      limit: limit,
      offset: offset,
    );
    
    print('📦 [REPO] SQLite devolvió ${localHabits.length} hábitos');

    // 2. Si es la primera página y SQLite está vacío, cargar desde servidor
    if (offset == 0 && localHabits.isEmpty && await _networkInfo.isConnected) {
      print('🌐 [REPO] SQLite vacío y hay internet, cargando desde Supabase...');
      try {
        // Cargar todos los hábitos del servidor
        final remoteHabits = await _remoteDataSource.getHabitsByUserId(email);
        print('✅ [REPO] Supabase devolvió ${remoteHabits.length} hábitos');
        
        if (remoteHabits.isNotEmpty) {
          // Guardar en SQLite
          await _localDataSource.saveHabits(remoteHabits);
          print('💾 [REPO] Guardados ${remoteHabits.length} hábitos en SQLite');
          // Devolver la primera página
          return remoteHabits.take(limit).toList();
        }
      } catch (e) {
        print('❌ [REPO] Error cargando desde Supabase: $e');
        // Si falla, devolver lista vacía
        return [];
      }
    }

    // 3. Si ya hay datos locales, sincronizar en segundo plano
    if (offset == 0 && localHabits.isNotEmpty && await _networkInfo.isConnected) {
      print('🔄 [REPO] Sincronizando en segundo plano...');
      _syncInBackground(email);
    }

    return localHabits;
  }

  @override
  Future<Either<Failure, String>> createHabit(HabitEntity habit) async {
    try {
      // 1. Guardar en SQLite primero (offline-first)
      await _localDataSource.createHabit(habit);

      // 2. Intentar guardar en Supabase si hay internet
      if (await _networkInfo.isConnected) {
        try {
          final remoteId = await _remoteDataSource.createHabit(habit);
          return Right(remoteId ?? habit.id);
        } catch (e) {
          // Si falla, marcar como pendiente de sincronización
          await _syncService.markPendingSync(
            entityType: 'habit',
            entityId: habit.id,
            action: 'create',
            data: _habitToJson(habit),
          );
          return Right(habit.id);
        }
      } else {
        // Sin internet, marcar para sincronizar después
        await _syncService.markPendingSync(
          entityType: 'habit',
          entityId: habit.id,
          action: 'create',
          data: _habitToJson(habit),
        );
        return Right(habit.id);
      }
    } catch (e) {
      return Left(ServerFailure(message: 'Error al crear hábito: ${e.toString()}'));
    }
  }

  @override
  Future<void> updateHabit(HabitEntity habit) async {
    // 1. Actualizar en SQLite primero
    await _localDataSource.updateHabit(habit);

    // 2. Intentar actualizar en Supabase si hay internet
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.updateHabit(habit);
      } catch (e) {
        // Si falla, marcar como pendiente de sincronización
        await _syncService.markPendingSync(
          entityType: 'habit',
          entityId: habit.id,
          action: 'update',
          data: _habitToJson(habit),
        );
      }
    } else {
      // Sin internet, marcar para sincronizar después
      await _syncService.markPendingSync(
        entityType: 'habit',
        entityId: habit.id,
        action: 'update',
        data: _habitToJson(habit),
      );
    }
  }

  @override
  Future<void> updateHabitProgress(
    String habitId,
    String progressId,
    int newCounter,
  ) async {
    // 1. Actualizar en SQLite primero
    await _localDataSource.incrementHabitProgress(
      habitId: habitId,
      progressId: progressId,
      newCounter: newCounter,
    );

    // 2. Intentar actualizar en Supabase si hay internet
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.incrementHabitProgress(
          habitId: habitId,
          progressId: progressId,
          newCounter: newCounter,
        );
      } catch (e) {
        // Si falla, marcar como pendiente de sincronización
        await _syncService.markPendingSync(
          entityType: 'progress',
          entityId: progressId,
          action: 'update',
          data: {
            'id': progressId,
            'habit_id': habitId,
            'daily_counter': newCounter,
          },
        );
      }
    } else {
      // Sin internet, marcar para sincronizar después
      await _syncService.markPendingSync(
        entityType: 'progress',
        entityId: progressId,
        action: 'update',
        data: {
          'id': progressId,
          'habit_id': habitId,
          'daily_counter': newCounter,
        },
      );
    }
  }

  @override
  Future<String?> createHabitProgress({
    required String habitId,
    required String date,
    required int dailyCounter,
    required int dailyGoal,
  }) async {
    // Generar ID local
    final progressId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final progress = HabitProgress(
      id: progressId,
      habitId: habitId,
      date: date,
      dailyGoal: dailyGoal,
      dailyCounter: dailyCounter,
    );

    // 1. Guardar en SQLite primero
    await _localDataSource.createHabitProgress(progress);

    // 2. Intentar guardar en Supabase si hay internet
    if (await _networkInfo.isConnected) {
      try {
        final remoteId = await _remoteDataSource.createHabitProgress(progress);
        return remoteId;
      } catch (e) {
        // Si falla, marcar como pendiente de sincronización
        await _syncService.markPendingSync(
          entityType: 'progress',
          entityId: progressId,
          action: 'create',
          data: {
            'id': progressId,
            'habit_id': habitId,
            'date': date,
            'daily_goal': dailyGoal,
            'daily_counter': dailyCounter,
          },
        );
        return progressId;
      }
    } else {
      // Sin internet, marcar para sincronizar después
      await _syncService.markPendingSync(
        entityType: 'progress',
        entityId: progressId,
        action: 'create',
        data: {
          'id': progressId,
          'habit_id': habitId,
          'date': date,
          'daily_goal': dailyGoal,
          'daily_counter': dailyCounter,
        },
      );
      return progressId;
    }
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    // 1. Eliminar de SQLite primero
    await _localDataSource.deleteHabit(habitId);

    // 2. Intentar eliminar en Supabase si hay internet
    if (await _networkInfo.isConnected) {
      try {
        await _remoteDataSource.deleteHabit(habitId);
      } catch (e) {
        // Si falla, marcar como pendiente de sincronización
        await _syncService.markPendingSync(
          entityType: 'habit',
          entityId: habitId,
          action: 'delete',
          data: {'id': habitId},
        );
      }
    } else {
      // Sin internet, marcar para sincronizar después
      await _syncService.markPendingSync(
        entityType: 'habit',
        entityId: habitId,
        action: 'delete',
        data: {'id': habitId},
      );
    }
  }

  /// Sincroniza datos en segundo plano sin bloquear la UI
  Future<void> _syncInBackground(String userId) async {
    try {
      // Sincronizar cambios pendientes primero
      await _syncService.syncPendingChanges();

      // Obtener datos actualizados del servidor
      final remoteHabits = await _remoteDataSource.getHabitsByUserId(userId);

      // Solo actualizar SQLite si se obtuvieron datos exitosamente
      if (remoteHabits.isNotEmpty) {
        await _localDataSource.clearAllHabits(userId);
        await _localDataSource.saveHabits(remoteHabits);
      }
    } catch (e) {
      // Sincronización silenciosa, no afecta la UX
      // Los datos locales permanecen intactos
    }
  }

  /// Convierte HabitEntity a Map para sincronización
  Map<String, dynamic> _habitToJson(HabitEntity habit) {
    return {
      'id': habit.id,
      'user_id': habit.userId,
      'title': habit.title,
      'description': habit.description,
      'icon': habit.icon,
      'type': habit.type.name,
      'daily_goal': habit.dailyGoal,
      'initial_date': habit.initialDate,
      'progress': habit.progress.map((p) => {
        'id': p.id,
        'habit_id': p.habitId,
        'date': p.date,
        'daily_goal': p.dailyGoal,
        'daily_counter': p.dailyCounter,
      }).toList(),
    };
  }

  /// Método público para sincronización manual
  Future<SyncResult> syncWithRemote(String userId) async {
    final result = await _syncService.syncPendingChanges();
    
    if (await _networkInfo.isConnected) {
      await _syncInBackground(userId);
    }
    
    return result;
  }

  /// Obtiene el número de cambios pendientes de sincronización
  Future<int> getPendingSyncCount() async {
    return await _syncService.getPendingCount();
  }
}

import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/core/network/network_info.dart';
import 'package:find_your_mind/core/services/sync_service.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_local_datasource.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

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
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource,
       _networkInfo = networkInfo,
       _syncService = syncService;

  @override
  Future<List<HabitEntity>> getHabitsByEmail(String email) async {
    // 1. Cargar desde SQLite primero (respuesta rápida, SIEMPRE)
    final localHabits = await _localDataSource.getHabitsByUserId(email);

    // 2. Si hay datos locales, retornarlos inmediatamente y sincronizar en segundo plano
    if (localHabits.isNotEmpty) {
      print(
        '✅ [REPO] Retornando ${localHabits.length} hábitos locales inmediatamente',
      );

      // Sincronizar en segundo plano SIN esperar
      _networkInfo.isConnected.then((isConnected) {
        if (isConnected) {
          unawaited(_syncInBackground(email));
        }
      });

      return localHabits;
    }

    // 3. Si SQLite está vacío, intentar cargar desde servidor (solo si hay internet)
    if (await _networkInfo.isConnected) {
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

    // 4. Sin datos locales y sin internet
    return localHabits; // Lista vacía
  }

  @override
  Future<List<HabitEntity>> getHabitsByEmailPaginated({
    required String email,
    int limit = 10,
    int offset = 0,
  }) async {
    print(
      '🔍 [REPO] getHabitsByEmailPaginated - email: $email, offset: $offset, limit: $limit',
    );

    // 1. Cargar desde SQLite primero (SIEMPRE, sin esperar verificación de red)
    final localHabits = await _localDataSource.getHabitsByUserIdPaginated(
      userId: email,
      limit: limit,
      offset: offset,
    );

    print('📦 [REPO] SQLite devolvió ${localHabits.length} hábitos');

    // 2. Si hay datos locales, retornarlos inmediatamente y sincronizar en segundo plano
    if (localHabits.isNotEmpty) {
      print('✅ [REPO] Retornando datos locales inmediatamente');

      // Solo en la primera página, sincronizar en segundo plano
      if (offset == 0) {
        print('🔄 [REPO] Iniciando sincronización en segundo plano...');
        // Verificar conectividad y sincronizar SIN esperar (unawaited)
        _networkInfo.isConnected.then((isConnected) {
          if (isConnected) {
            unawaited(_syncInBackground(email));
          }
        });
      }

      return localHabits;
    }

    // 3. Si SQLite está vacío, intentar cargar desde servidor (solo si hay internet)
    if (await _networkInfo.isConnected) {
      print(
        '🌐 [REPO] SQLite vacío y hay internet, cargando desde Supabase...',
      );
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

    // 4. Sin datos locales y sin internet, retornar lista vacía
    print('📭 [REPO] Sin datos locales y sin conexión');
    return [];
  }

  @override
  Future<Either<Failure, String?>> createHabit(HabitEntity habit) async {
    try {
      // ✅ Usar el UUID que viene del provider (ya generado)
      // Si por alguna razón no tiene ID, generar uno aquí como fallback
      final String habitId = habit.id.isNotEmpty ? habit.id : const Uuid().v4();
      final HabitEntity habitWithId = habit.copyWith(id: habitId);

      // 1. Guardar en SQLite primero (offline-first) - RESPUESTA INMEDIATA
      await _localDataSource.createHabit(habitWithId);

      // 2. 🌐 Sincronizar con Supabase ESPERANDO a que termine (para evitar errores de FK)
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.createHabit(habitWithId);
          print('✅ Hábito sincronizado con Supabase - ID: $habitId');
        } catch (e) {
          print('⚠️ Error sincronizando con Supabase: $e');
          // Si falla, marcar como pendiente de sincronización
          await _syncService.markPendingSync(
            entityType: 'habit',
            entityId: habitId,
            action: 'create',
            data: _habitToJson(habitWithId),
          );
          // Continuar y retornar el ID local, el usuario puede trabajar offline
        }
      } else {
        // Sin internet, marcar para sincronizar después
        await _syncService.markPendingSync(
          entityType: 'habit',
          entityId: habitId,
          action: 'create',
          data: _habitToJson(habitWithId),
        );
      }

      // 3. Retornar ID único (el mismo que recibimos del provider)
      return Right(habitId);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al crear hábito: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateHabit(HabitEntity habit) async {
    try {
      // 1. Actualizar en SQLite primero
      await _localDataSource.updateHabit(habit);

      // 2. Intentar actualizar en Supabase si hay internet
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.updateHabit(habit);
          return const Right(null);
        } catch (e) {
          // Si falla, marcar como pendiente de sincronización
          await _syncService.markPendingSync(
            entityType: 'habit',
            entityId: habit.id,
            action: 'update',
            data: _habitToJson(habit),
          );
          return const Right(null); // Éxito local, sincronización pendiente
        }
      } else {
        // Sin internet, marcar para sincronizar después
        await _syncService.markPendingSync(
          entityType: 'habit',
          entityId: habit.id,
          action: 'update',
          data: _habitToJson(habit),
        );
        return const Right(null); // Éxito local, sincronización pendiente
      }
    } catch (e) {
      return Left(
        CacheFailure(message: 'Error al actualizar hábito: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateHabitProgress(
    String habitId,
    String progressId,
    int newCounter,
  ) async {
    try {
      // 🔍 1. Obtener datos completos del progreso ANTES de actualizar
      final currentProgress = await _localDataSource.getHabitProgressById(
        progressId,
      );

      if (currentProgress == null) {
        return Left(CacheFailure(message: 'Progreso no encontrado'));
      }

      // 💾 2. Actualizar en SQLite primero
      await _localDataSource.incrementHabitProgress(
        habitId: habitId,
        progressId: progressId,
        newCounter: newCounter,
      );

      // 🚀 3. Sincronizar con Supabase en SEGUNDO PLANO (no bloqueante)
      if (await _networkInfo.isConnected) {
        // Usar unawaited para no bloquear la UI
        unawaited(
          _remoteDataSource
              .incrementHabitProgress(
                habitId: habitId,
                progressId: progressId,
                newCounter: newCounter,
              )
              .then((_) {
                print('✅ Progreso sincronizado con Supabase');
              })
              .catchError((e) async {
                print('⚠️ Error sincronizando progreso: $e');
                // Si falla, marcar como pendiente de sincronización con DATOS COMPLETOS
                await _syncService.markPendingSync(
                  entityType: 'progress',
                  entityId: progressId,
                  action: 'update',
                  data: {
                    'id': progressId,
                    'habit_id': habitId,
                    'date': currentProgress.date,
                    'daily_goal': currentProgress.dailyGoal,
                    'daily_counter': newCounter,
                  },
                );
              }),
        );
      } else {
        // Sin internet, marcar para sincronizar después con DATOS COMPLETOS
        await _syncService.markPendingSync(
          entityType: 'progress',
          entityId: progressId,
          action: 'update',
          data: {
            'id': progressId,
            'habit_id': habitId,
            'date': currentProgress.date,
            'daily_goal': currentProgress.dailyGoal,
            'daily_counter': newCounter,
          },
        );
      }

      // 4. Retornar éxito INMEDIATAMENTE (sin esperar a Supabase)
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Error al actualizar progreso: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, String?>> createHabitProgress({
    required HabitProgress habitProgress,
  }) async {
    try {
      final String progressId = habitProgress.id.isNotEmpty 
          ? habitProgress.id 
          : const Uuid().v4();
      final HabitProgress progressWithId = habitProgress.copyWith(id: progressId);

      // 1. Guardar en SQLite primero (offline-first) y obtener el ID real
      final String? savedId = await _localDataSource.createHabitProgress(progressWithId);
      final String finalProgressId = savedId ?? progressId;
      
      final HabitProgress finalProgress = progressWithId.copyWith(id: finalProgressId);

      if (kDebugMode) {
        print('✅ Progreso creado/recuperado localmente - ID: $finalProgressId');
      }

      // 2. 🚀 Sincronizar con Supabase en SEGUNDO PLANO (no bloqueante)
      if (await _networkInfo.isConnected) {
        // Usar unawaited para no bloquear la UI
        unawaited(
          _remoteDataSource.createHabitProgress(finalProgress).then((_) {
            if (kDebugMode) {
              print('✅ [REMOTE] Progreso sincronizado con Supabase - ID: $finalProgressId');
            }
          }).catchError((e) async {
            print('⚠️ Error sincronizando progreso: $e');
            // Si falla, marcar como pendiente de sincronización
            await _syncService.markPendingSync(
              entityType: 'progress',
              entityId: finalProgressId,
              action: 'create',
              data: {
                'id': finalProgressId,
                'habit_id': finalProgress.habitId,
                'date': finalProgress.date,
                'daily_goal': finalProgress.dailyGoal,
                'daily_counter': finalProgress.dailyCounter,
              },
            );
          }),
        );
      } else {
        // Sin internet, marcar para sincronizar después
        await _syncService.markPendingSync(
          entityType: 'progress',
          entityId: finalProgressId,
          action: 'create',
          data: {
            'id': finalProgressId,
            'habit_id': finalProgress.habitId,
            'date': finalProgress.date,
            'daily_goal': finalProgress.dailyGoal,
            'daily_counter': finalProgress.dailyCounter,
          },
        );
      }

      // 3. Retornar ID único INMEDIATAMENTE (sin esperar a Supabase)
      return Right(finalProgressId);
    } catch (e) {
      return Left(
        ServerFailure(message: 'Error al crear progreso: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String habitId) async {
    try {
      // 1. Eliminar de SQLite primero
      await _localDataSource.deleteHabit(habitId);
      // Eliminar Progresos de el Habito
      await _localDataSource.deleteHabitProgress(habitId);

      // 2. Intentar eliminar en Supabase si hay internet
      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.deleteHabit(habitId);
          return const Right(null);
        } catch (e) {
          // Si falla, marcar como pendiente de sincronización
          await _syncService.markPendingSync(
            entityType: 'habit',
            entityId: habitId,
            action: 'delete',
            data: {'id': habitId},
          );
          return const Right(null); // Éxito local, sincronización pendiente
        }
      } else {
        // Sin internet, marcar para sincronizar después
        await _syncService.markPendingSync(
          entityType: 'habit',
          entityId: habitId,
          action: 'delete',
          data: {'id': habitId},
        );
        return const Right(null); // Éxito local, sincronización pendiente
      }
    } catch (e) {
      return Left(
        CacheFailure(message: 'Error al eliminar hábito: ${e.toString()}'),
      );
    }
  }

  /// Sincroniza datos en segundo plano sin bloquear la UI
  Future<SyncResult> _syncInBackground(String userId) async {
    try {
      // Sincronizar cambios pendientes primero
      final syncResult = await _syncService.syncPendingChanges();

      // Obtener datos actualizados del servidor
      final remoteHabits = await _remoteDataSource.getHabitsByUserId(userId);

      // Solo actualizar SQLite si se obtuvieron datos exitosamente
      if (remoteHabits.isNotEmpty) {
        await _localDataSource.clearAllHabits(userId);
        await _localDataSource.saveHabits(remoteHabits);
      }

      return syncResult;
    } catch (e) {
      // Sincronización silenciosa, no afecta la UX
      // Los datos locales permanecen intactos
      return SyncResult(
        success: 0,
        failed: 1,
        errors: ['Error de sincronización: ${e.toString()}'],
      );
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
      'progress': habit.progress
          .map(
            (p) => {
              'id': p.id,
              'habit_id': p.habitId,
              'date': p.date,
              'daily_goal': p.dailyGoal,
              'daily_counter': p.dailyCounter,
            },
          )
          .toList(),
    };
  }

  /// Método público para sincronización manual
  Future<SyncResult> syncWithRemote(String userId) async {
    if (!await _networkInfo.isConnected) {
      return SyncResult(
        success: 0,
        failed: 1,
        errors: ['Sin conexión a Internet'],
      );
    }

    final SyncResult syncResult = await _syncInBackground(userId);
    return syncResult;
  }

  /// Obtiene el número de cambios pendientes de sincronización
  Future<int> getPendingSyncCount() async {
    return await _syncService.getPendingCount();
  }
}

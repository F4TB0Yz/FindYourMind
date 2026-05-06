import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/core/network/network_info.dart';
import 'package:find_your_mind/core/services/sync_service.dart';
import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_local_datasource.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:uuid/uuid.dart';

class HabitRepositoryImpl implements HabitRepository {
  final HabitsRemoteDataSource _remoteDataSource;
  final HabitsLocalDatasource _localDataSource;
  final NetworkInfo _networkInfo;
  final SyncService _syncService;
  static const Duration _startupSyncDelay = Duration(milliseconds: 1800);

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
    final localHabits = await _localDataSource.getHabitsByUserId(email);

    if (localHabits.isNotEmpty) {
      AppLogger.d(
        '[REPO] Retornando ${localHabits.length} hábitos locales inmediatamente',
      );

      _networkInfo.isConnected.then((isConnected) {
        if (isConnected) {
          unawaited(_syncInBackground(email));
        }
      });

      return localHabits;
    }

    if (await _networkInfo.isConnected) {
      try {
        final remoteHabits = await _remoteDataSource.getHabitsByUserId(email);

        if (remoteHabits.isNotEmpty) {
          await _localDataSource.saveHabits(remoteHabits);
          return remoteHabits;
        }
      } catch (_) {
        return [];
      }
    }

    return localHabits;
  }

  @override
  Future<List<HabitEntity>> getHabitsByEmailPaginated({
    required String email,
    int limit = 10,
    int offset = 0,
  }) async {
    AppLogger.d(
      '[REPO] getHabitsByEmailPaginated - email: $email, offset: $offset, limit: $limit',
    );

    final localHabits = await _localDataSource.getHabitsByUserIdPaginated(
      userId: email,
      limit: limit,
      offset: offset,
    );

    AppLogger.d('[REPO] SQLite devolvió ${localHabits.length} hábitos');

    if (localHabits.isNotEmpty) {
      if (offset == 0) {
        unawaited(
          Future<void>.delayed(_startupSyncDelay, () async {
            if (await _networkInfo.isConnected) {
              await _syncInBackground(email);
            }
          }),
        );
      }

      return localHabits;
    }

    if (await _networkInfo.isConnected) {
      try {
        final remoteHabits = await _remoteDataSource.getHabitsByUserId(email);
        if (remoteHabits.isNotEmpty) {
          await _localDataSource.saveHabits(remoteHabits);
          return remoteHabits.take(limit).toList();
        }
      } catch (e) {
        AppLogger.e('[REPO] Error cargando desde Supabase', error: e);
        return [];
      }
    }

    return [];
  }

  @override
  Future<Either<Failure, String?>> createHabit(HabitEntity habit) async {
    try {
      final habitId = habit.id.isNotEmpty ? habit.id : const Uuid().v4();
      final habitWithId = habit.copyWith(id: habitId);

      await _localDataSource.createHabit(habitWithId);

      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.createHabit(habitWithId);
        } catch (e) {
          AppLogger.w('[REPO] Error sincronizando hábito', error: e);
          await _syncService.markPendingSync(
            entityType: 'habit',
            entityId: habitId,
            action: 'create',
            data: _habitToJson(habitWithId),
          );
        }
      } else {
        await _syncService.markPendingSync(
          entityType: 'habit',
          entityId: habitId,
          action: 'create',
          data: _habitToJson(habitWithId),
        );
      }

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
      await _localDataSource.updateHabit(habit);

      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.updateHabit(habit);
          return const Right(null);
        } catch (_) {
          await _syncService.markPendingSync(
            entityType: 'habit',
            entityId: habit.id,
            action: 'update',
            data: _habitToJson(habit),
          );
          return const Right(null);
        }
      }

      await _syncService.markPendingSync(
        entityType: 'habit',
        entityId: habit.id,
        action: 'update',
        data: _habitToJson(habit),
      );
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Error al actualizar hábito: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateHabitLogValue({
    required String habitId,
    required String logId,
    required int value,
  }) async {
    try {
      final currentLog = await _localDataSource.getHabitLogById(logId);

      if (currentLog == null) {
        return Left(CacheFailure(message: 'Log no encontrado'));
      }

      await _localDataSource.updateHabitLogValue(
        habitId: habitId,
        logId: logId,
        value: value,
      );

      if (await _networkInfo.isConnected) {
        unawaited(
          _remoteDataSource
              .updateHabitLogValue(
                habitId: habitId,
                logId: logId,
                value: value,
              )
              .catchError((e) async {
                AppLogger.w('[REPO] Error sincronizando log', error: e);
                await _syncService.markPendingSync(
                  entityType: 'log',
                  entityId: logId,
                  action: 'update',
                  data: {
                    'id': logId,
                    'habit_id': habitId,
                    'date': currentLog.date,
                    'value': value,
                  },
                );
              }),
        );
      } else {
        await _syncService.markPendingSync(
          entityType: 'log',
          entityId: logId,
          action: 'update',
          data: {
            'id': logId,
            'habit_id': habitId,
            'date': currentLog.date,
            'value': value,
          },
        );
      }

      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Error al actualizar log: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, String?>> createHabitLog({
    required HabitLog habitLog,
  }) async {
    try {
      final logId = habitLog.id.isNotEmpty ? habitLog.id : const Uuid().v4();
      final logWithId = habitLog.copyWith(id: logId);

      final savedId = await _localDataSource.createHabitLog(logWithId);
      final finalLogId = savedId ?? logId;
      final finalLog = logWithId.copyWith(id: finalLogId);

      if (await _networkInfo.isConnected) {
        unawaited(
          _remoteDataSource.createHabitLog(finalLog).catchError((e) async {
            AppLogger.w('[REPO] Error sincronizando log', error: e);
            await _syncService.markPendingSync(
              entityType: 'log',
              entityId: finalLogId,
              action: 'create',
              data: {
                'id': finalLogId,
                'habit_id': finalLog.habitId,
                'date': finalLog.date,
                'value': finalLog.value,
              },
            );
            return null;
          }),
        );
      } else {
        await _syncService.markPendingSync(
          entityType: 'log',
          entityId: finalLogId,
          action: 'create',
          data: {
            'id': finalLogId,
            'habit_id': finalLog.habitId,
            'date': finalLog.date,
            'value': finalLog.value,
          },
        );
      }

      return Right(finalLogId);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al crear log: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteHabit(String habitId) async {
    try {
      await _localDataSource.deleteHabit(habitId);
      await _localDataSource.deleteHabitLogs(habitId);

      if (await _networkInfo.isConnected) {
        try {
          await _remoteDataSource.deleteHabit(habitId);
          return const Right(null);
        } catch (_) {
          await _syncService.markPendingSync(
            entityType: 'habit',
            entityId: habitId,
            action: 'delete',
            data: {'id': habitId},
          );
          return const Right(null);
        }
      }

      await _syncService.markPendingSync(
        entityType: 'habit',
        entityId: habitId,
        action: 'delete',
        data: {'id': habitId},
      );
      return const Right(null);
    } catch (e) {
      return Left(
        CacheFailure(message: 'Error al eliminar hábito: ${e.toString()}'),
      );
    }
  }

  Future<SyncResult> _syncInBackground(String userId) async {
    try {
      final syncResult = await _syncService.syncPendingChanges();
      final remoteHabits = await _remoteDataSource.getHabitsByUserId(userId);

      if (remoteHabits.isNotEmpty) {
        await _localDataSource.clearAllHabits(userId);
        await _localDataSource.saveHabits(remoteHabits);
      }

      return syncResult;
    } catch (e) {
      return SyncResult(
        success: 0,
        failed: 1,
        errors: ['Error de sincronización: ${e.toString()}'],
      );
    }
  }

  Map<String, dynamic> _habitToJson(HabitEntity habit) {
    return {
      'id': habit.id,
      'user_id': habit.userId,
      'title': habit.title,
      'description': habit.description,
      'icon': habit.icon,
      'category': habit.category.name,
      'tracking_type': habit.trackingType.name,
      'target_value': habit.targetValue,
      'color': habit.color,
      'unit': habit.unit,
      'initial_date': habit.initialDate,
      'logs': habit.logs
          .map(
            (log) => {
              'id': log.id,
              'habit_id': log.habitId,
              'date': log.date,
              'value': log.value,
            },
          )
          .toList(),
    };
  }

  Future<SyncResult> syncWithRemote(String userId) async {
    if (!await _networkInfo.isConnected) {
      return SyncResult(
        success: 0,
        failed: 1,
        errors: ['Sin conexión a Internet'],
      );
    }

    return _syncInBackground(userId);
  }

  Future<int> getPendingSyncCount() async {
    return _syncService.getPendingCount();
  }
}

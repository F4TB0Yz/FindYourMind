import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/core/network/network_info.dart';
import 'package:find_your_mind/core/services/sync_service.dart';
import 'package:find_your_mind/features/habits/data/repositories/habit_repository_impl.dart';
import '../../../../fixtures/habit_fixtures.dart';
import '../../../../fixtures/mocks.dart';

void main() {
  late HabitRepositoryImpl repository;
  late MockHabitsRemoteDataSource mockRemoteDataSource;
  late MockHabitsLocalDatasource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;
  late MockSyncService mockSyncService;

  setUpAll(() {
    registerFallbackValue(tHabitEntity);
    registerFallbackValue(tHabitLog);
    registerFallbackValue(<String, dynamic>{});
  });

  setUp(() {
    mockRemoteDataSource = MockHabitsRemoteDataSource();
    mockLocalDataSource = MockHabitsLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();
    mockSyncService = MockSyncService();

    repository = HabitRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
      syncService: mockSyncService,
    );
  });

  group('createHabit', () {
    test('online + remote success: returns habit id', () async {
      when(() => mockLocalDataSource.createHabit(any())).thenAnswer((_) async => tHabitId);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.createHabit(any())).thenAnswer((_) async => tHabitId);

      final result = await repository.createHabit(tHabitEntity);

      expect(result, Right(tHabitId));
      verify(() => mockLocalDataSource.createHabit(any())).called(1);
      verify(() => mockRemoteDataSource.createHabit(any())).called(1);
      verifyNever(() => mockSyncService.markPendingSync(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        action: any(named: 'action'),
        data: any(named: 'data'),
      ));
    });

    test('online + remote fail: queues to sync', () async {
      when(() => mockLocalDataSource.createHabit(any())).thenAnswer((_) async => tHabitId);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.createHabit(any())).thenThrow(Exception('Server error'));
      when(() => mockSyncService.markPendingSync(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        action: any(named: 'action'),
        data: any(named: 'data'),
      )).thenAnswer((_) async {});

      final result = await repository.createHabit(tHabitEntity);

      expect(result, Right(tHabitId));
      verify(() => mockSyncService.markPendingSync(
        entityType: 'habit',
        entityId: any(named: 'entityId'),
        action: 'create',
        data: any(named: 'data'),
      )).called(1);
    });

    test('offline: queues to sync', () async {
      when(() => mockLocalDataSource.createHabit(any())).thenAnswer((_) async => tHabitId);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockSyncService.markPendingSync(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        action: any(named: 'action'),
        data: any(named: 'data'),
      )).thenAnswer((_) async {});

      final result = await repository.createHabit(tHabitEntity);

      expect(result, Right(tHabitId));
      verify(() => mockSyncService.markPendingSync(
        entityType: 'habit',
        entityId: any(named: 'entityId'),
        action: 'create',
        data: any(named: 'data'),
      )).called(1);
    });

    test('local fail: returns Left CacheFailure', () async {
      when(() => mockLocalDataSource.createHabit(any())).thenThrow(Exception('DB error'));

      final result = await repository.createHabit(tHabitEntity);

      expect(result, isA<Left<Failure, String?>>());
    });
  });

  group('updateHabit', () {
    test('online + remote success: returns Right(null)', () async {
      when(() => mockLocalDataSource.updateHabit(any())).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.updateHabit(any())).thenAnswer((_) async {});

      final result = await repository.updateHabit(tHabitEntity);

      expect(result, const Right(null));
      verify(() => mockLocalDataSource.updateHabit(any())).called(1);
      verify(() => mockRemoteDataSource.updateHabit(any())).called(1);
    });

    test('online + remote fail: queues to sync, returns Right(null)', () async {
      when(() => mockLocalDataSource.updateHabit(any())).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.updateHabit(any())).thenThrow(Exception('Error'));
      when(() => mockSyncService.markPendingSync(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        action: any(named: 'action'),
        data: any(named: 'data'),
      )).thenAnswer((_) async {});

      final result = await repository.updateHabit(tHabitEntity);

      expect(result, const Right(null));
      verify(() => mockSyncService.markPendingSync(
        entityType: 'habit',
        entityId: any(named: 'entityId'),
        action: 'update',
        data: any(named: 'data'),
      )).called(1);
    });

    test('offline: queues to sync', () async {
      when(() => mockLocalDataSource.updateHabit(any())).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockSyncService.markPendingSync(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        action: any(named: 'action'),
        data: any(named: 'data'),
      )).thenAnswer((_) async {});

      final result = await repository.updateHabit(tHabitEntity);

      expect(result, const Right(null));
      verify(() => mockSyncService.markPendingSync(
        entityType: 'habit',
        entityId: any(named: 'entityId'),
        action: 'update',
        data: any(named: 'data'),
      )).called(1);
    });

    test('local fail: returns Left CacheFailure', () async {
      when(() => mockLocalDataSource.updateHabit(any())).thenThrow(Exception('DB error'));

      final result = await repository.updateHabit(tHabitEntity);

      expect(result.isLeft(), true);
    });
  });

  group('deleteHabit', () {
    test('online + remote success: returns Right(null)', () async {
      when(() => mockLocalDataSource.deleteHabit(any())).thenAnswer((_) async {});
      when(() => mockLocalDataSource.deleteHabitLogs(any())).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.deleteHabit(any())).thenAnswer((_) async {});

      final result = await repository.deleteHabit(tHabitId);

      expect(result, const Right(null));
    });

    test('online + remote fail: queues to sync', () async {
      when(() => mockLocalDataSource.deleteHabit(any())).thenAnswer((_) async {});
      when(() => mockLocalDataSource.deleteHabitLogs(any())).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.deleteHabit(any())).thenThrow(Exception('Error'));
      when(() => mockSyncService.markPendingSync(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        action: any(named: 'action'),
        data: any(named: 'data'),
      )).thenAnswer((_) async {});

      final result = await repository.deleteHabit(tHabitId);

      expect(result, const Right(null));
    });

    test('offline: queues to sync', () async {
      when(() => mockLocalDataSource.deleteHabit(any())).thenAnswer((_) async {});
      when(() => mockLocalDataSource.deleteHabitLogs(any())).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockSyncService.markPendingSync(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        action: any(named: 'action'),
        data: any(named: 'data'),
      )).thenAnswer((_) async {});

      final result = await repository.deleteHabit(tHabitId);

      expect(result, const Right(null));
    });

    test('local fail: returns Left CacheFailure', () async {
      when(() => mockLocalDataSource.deleteHabit(any())).thenThrow(Exception('DB error'));

      final result = await repository.deleteHabit(tHabitId);

      expect(result.isLeft(), true);
    });
  });

  group('createHabitLog', () {
    test('online: returns log id (remote is unawaited)', () async {
      when(() => mockLocalDataSource.createHabitLog(any())).thenAnswer((_) async => tLogId);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.createHabitLog(any())).thenAnswer((_) async => tLogId);

      final result = await repository.createHabitLog(habitLog: tHabitLog);

      expect(result, Right(tLogId));
      verify(() => mockLocalDataSource.createHabitLog(any())).called(1);
    });

    test('offline + remote fail: queues to sync', () async {
      when(() => mockLocalDataSource.createHabitLog(any())).thenAnswer((_) async => tLogId);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockSyncService.markPendingSync(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        action: any(named: 'action'),
        data: any(named: 'data'),
      )).thenAnswer((_) async {});

      final result = await repository.createHabitLog(habitLog: tHabitLog);

      expect(result, Right(tLogId));
      verify(() => mockSyncService.markPendingSync(
        entityType: 'log',
        entityId: any(named: 'entityId'),
        action: 'create',
        data: any(named: 'data'),
      )).called(1);
    });

    test('local fail: returns Left ServerFailure', () async {
      when(() => mockLocalDataSource.createHabitLog(any())).thenThrow(Exception('DB error'));

      final result = await repository.createHabitLog(habitLog: tHabitLog);

      expect(result.isLeft(), true);
    });
  });

  group('updateHabitLogValue', () {
    test('online + log exists: returns Right(null)', () async {
      when(() => mockLocalDataSource.getHabitLogById(any()))
          .thenAnswer((_) async => tHabitLog);
      when(() => mockLocalDataSource.updateHabitLogValue(
        habitId: any(named: 'habitId'),
        logId: any(named: 'logId'),
        value: any(named: 'value'),
      )).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.updateHabitLogValue(
        habitId: any(named: 'habitId'),
        logId: any(named: 'logId'),
        value: any(named: 'value'),
      )).thenAnswer((_) async {});

      final result = await repository.updateHabitLogValue(
        habitId: tHabitId,
        logId: tLogId,
        value: 5,
      );

      expect(result, const Right(null));
    });

    test('offline + log exists: queues to sync', () async {
      when(() => mockLocalDataSource.getHabitLogById(any()))
          .thenAnswer((_) async => tHabitLog);
      when(() => mockLocalDataSource.updateHabitLogValue(
        habitId: any(named: 'habitId'),
        logId: any(named: 'logId'),
        value: any(named: 'value'),
      )).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockSyncService.markPendingSync(
        entityType: any(named: 'entityType'),
        entityId: any(named: 'entityId'),
        action: any(named: 'action'),
        data: any(named: 'data'),
      )).thenAnswer((_) async {});

      final result = await repository.updateHabitLogValue(
        habitId: tHabitId,
        logId: tLogId,
        value: 5,
      );

      expect(result, const Right(null));
      verify(() => mockSyncService.markPendingSync(
        entityType: 'log',
        entityId: any(named: 'entityId'),
        action: 'update',
        data: any(named: 'data'),
      )).called(1);
    });

    test('log not found: returns Left CacheFailure', () async {
      when(() => mockLocalDataSource.getHabitLogById(any())).thenAnswer((_) async => null);

      final result = await repository.updateHabitLogValue(
        habitId: tHabitId,
        logId: tLogId,
        value: 5,
      );

      expect(result.isLeft(), true);
    });
  });

  group('getHabitsByEmail', () {
    test('local hit: returns local + background sync', () async {
      when(() => mockLocalDataSource.getHabitsByUserId(any()))
          .thenAnswer((_) async => [tHabitEntity]);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockSyncService.syncPendingChanges())
          .thenAnswer((_) async => SyncResult(success: 1, failed: 0, errors: []));
      when(() => mockRemoteDataSource.getHabitsByUserId(any()))
          .thenAnswer((_) async => [tHabitEntity]);

      final result = await repository.getHabitsByEmail(tUserId);

      expect(result.length, 1);
      expect(result.first.id, tHabitId);
    });

    test('local empty + online: fetches from remote', () async {
      when(() => mockLocalDataSource.getHabitsByUserId(any())).thenAnswer((_) async => []);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getHabitsByUserId(any()))
          .thenAnswer((_) async => [tHabitEntity]);
      when(() => mockLocalDataSource.saveHabits(any())).thenAnswer((_) async {});

      final result = await repository.getHabitsByEmail(tUserId);

      expect(result.length, 1);
      verify(() => mockLocalDataSource.saveHabits(any())).called(1);
    });

    test('local empty + offline: returns empty', () async {
      when(() => mockLocalDataSource.getHabitsByUserId(any())).thenAnswer((_) async => []);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getHabitsByEmail(tUserId);

      expect(result, isEmpty);
    });
  });

  group('getHabitsByEmailPaginated', () {
    test('local hit: returns local + delayed sync', () async {
      when(() => mockLocalDataSource.getHabitsByUserIdPaginated(
        userId: any(named: 'userId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => [tHabitEntity]);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockSyncService.syncPendingChanges())
          .thenAnswer((_) async => SyncResult(success: 1, failed: 0, errors: []));
      when(() => mockRemoteDataSource.getHabitsByUserId(any()))
          .thenAnswer((_) async => [tHabitEntity]);
      when(() => mockLocalDataSource.clearAllHabits(any())).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveHabits(any())).thenAnswer((_) async {});

      final result = await repository.getHabitsByEmailPaginated(
        email: tUserId,
        limit: 10,
        offset: 0,
      );

      expect(result.length, 1);
    });

    test('local empty + online: fetches and saves', () async {
      when(() => mockLocalDataSource.getHabitsByUserIdPaginated(
        userId: any(named: 'userId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => []);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getHabitsByUserId(any()))
          .thenAnswer((_) async => [tHabitEntity]);
      when(() => mockLocalDataSource.saveHabits(any())).thenAnswer((_) async {});

      final result = await repository.getHabitsByEmailPaginated(
        email: tUserId,
        limit: 10,
        offset: 0,
      );

      expect(result.length, 1);
    });

    test('local empty + offline: returns empty', () async {
      when(() => mockLocalDataSource.getHabitsByUserIdPaginated(
        userId: any(named: 'userId'),
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      )).thenAnswer((_) async => []);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getHabitsByEmailPaginated(
        email: tUserId,
        limit: 10,
        offset: 0,
      );

      expect(result, isEmpty);
    });
  });

  group('syncWithRemote', () {
    test('online: delegates to sync service', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockSyncService.syncPendingChanges())
          .thenAnswer((_) async => SyncResult(success: 2, failed: 0, errors: []));
      when(() => mockRemoteDataSource.getHabitsByUserId(any()))
          .thenAnswer((_) async => [tHabitEntity]);
      when(() => mockLocalDataSource.clearAllHabits(any())).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveHabits(any())).thenAnswer((_) async {});

      final result = await repository.syncWithRemote(tUserId);

      expect(result.success, 2);
    });

    test('offline: returns error result', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.syncWithRemote(tUserId);

      expect(result.success, 0);
      expect(result.failed, 1);
      expect(result.errors.first, contains('Sin conexión'));
    });
  });

  group('getPendingSyncCount', () {
    test('delegates to sync service', () async {
      when(() => mockSyncService.getPendingCount()).thenAnswer((_) async => 5);

      final result = await repository.getPendingSyncCount();

      expect(result, 5);
    });
  });
}
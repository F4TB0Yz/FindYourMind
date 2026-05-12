import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/core/services/sync_service.dart';
import 'package:find_your_mind/features/habits/data/repositories/habit_repository_impl.dart';

import '../../../../test_utils/test_output_style.dart';
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

  group(label('createHabit'), () {
    test(label('online + remote OK: devuelve id de hábito'), () async {
      when(
        () => mockLocalDataSource.createHabit(any()),
      ).thenAnswer((_) async => tHabitId);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.createHabit(any()),
      ).thenAnswer((_) async => tHabitId);

      final result = await repository.createHabit(tHabitEntity);

      expect(result, const Right(tHabitId));
      verify(() => mockLocalDataSource.createHabit(any())).called(1);
      verify(() => mockRemoteDataSource.createHabit(any())).called(1);
      verifyNever(
        () => mockSyncService.markPendingSync(
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          data: any(named: 'data'),
        ),
      );
    });

    test(label('online + remote falla: encola para sync'), () async {
      when(
        () => mockLocalDataSource.createHabit(any()),
      ).thenAnswer((_) async => tHabitId);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.createHabit(any()),
      ).thenThrow(Exception('Server error'));
      when(
        () => mockSyncService.markPendingSync(
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.createHabit(tHabitEntity);

      expect(result, const Right(tHabitId));
      verify(
        () => mockSyncService.markPendingSync(
          entityType: 'habit',
          entityId: any(named: 'entityId'),
          action: 'create',
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test(label('offline: encola para sync'), () async {
      when(
        () => mockLocalDataSource.createHabit(any()),
      ).thenAnswer((_) async => tHabitId);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockSyncService.markPendingSync(
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.createHabit(tHabitEntity);

      expect(result, const Right(tHabitId));
      verify(
        () => mockSyncService.markPendingSync(
          entityType: 'habit',
          entityId: any(named: 'entityId'),
          action: 'create',
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test(label('local falla: devuelve Left CacheFailure'), () async {
      when(
        () => mockLocalDataSource.createHabit(any()),
      ).thenThrow(Exception('DB error'));

      final result = await repository.createHabit(tHabitEntity);

      expect(result, isA<Left<Failure, String?>>());
    });
  });

  group(label('updateHabit'), () {
    test(label('online + remote OK: devuelve Right(null)'), () async {
      when(
        () => mockLocalDataSource.updateHabit(any()),
      ).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.updateHabit(any()),
      ).thenAnswer((_) async {});

      final result = await repository.updateHabit(tHabitEntity);

      expect(result, const Right(null));
      verify(() => mockLocalDataSource.updateHabit(any())).called(1);
      verify(() => mockRemoteDataSource.updateHabit(any())).called(1);
    });

    test(label('online + remote falla: encola para sync y devuelve Right(null)'), () async {
      when(
        () => mockLocalDataSource.updateHabit(any()),
      ).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.updateHabit(any()),
      ).thenThrow(Exception('Error'));
      when(
        () => mockSyncService.markPendingSync(
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.updateHabit(tHabitEntity);

      expect(result, const Right(null));
      verify(
        () => mockSyncService.markPendingSync(
          entityType: 'habit',
          entityId: any(named: 'entityId'),
          action: 'update',
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test(label('offline: encola para sync'), () async {
      when(
        () => mockLocalDataSource.updateHabit(any()),
      ).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockSyncService.markPendingSync(
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.updateHabit(tHabitEntity);

      expect(result, const Right(null));
      verify(
        () => mockSyncService.markPendingSync(
          entityType: 'habit',
          entityId: any(named: 'entityId'),
          action: 'update',
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test(label('local falla: devuelve Left CacheFailure'), () async {
      when(
        () => mockLocalDataSource.updateHabit(any()),
      ).thenThrow(Exception('DB error'));

      final result = await repository.updateHabit(tHabitEntity);

      expect(result.isLeft(), true);
    });
  });

  group(label('deleteHabit'), () {
    test(label('online + remote OK: devuelve Right(null)'), () async {
      when(
        () => mockLocalDataSource.deleteHabit(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockLocalDataSource.deleteHabitLogs(any()),
      ).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.deleteHabit(any()),
      ).thenAnswer((_) async {});

      final result = await repository.deleteHabit(tHabitId);

      expect(result, const Right(null));
    });

    test(label('online + remote falla: encola para sync'), () async {
      when(
        () => mockLocalDataSource.deleteHabit(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockLocalDataSource.deleteHabitLogs(any()),
      ).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.deleteHabit(any()),
      ).thenThrow(Exception('Error'));
      when(
        () => mockSyncService.markPendingSync(
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.deleteHabit(tHabitId);

      expect(result, const Right(null));
    });

    test(label('offline: encola para sync'), () async {
      when(
        () => mockLocalDataSource.deleteHabit(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockLocalDataSource.deleteHabitLogs(any()),
      ).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockSyncService.markPendingSync(
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.deleteHabit(tHabitId);

      expect(result, const Right(null));
    });

    test(label('local falla: devuelve Left CacheFailure'), () async {
      when(
        () => mockLocalDataSource.deleteHabit(any()),
      ).thenThrow(Exception('DB error'));

      final result = await repository.deleteHabit(tHabitId);

      expect(result.isLeft(), true);
    });
  });

  group(label('createHabitLog'), () {
    test(label('online: devuelve id de log (remote sin await)'), () async {
      when(
        () => mockLocalDataSource.createHabitLog(any()),
      ).thenAnswer((_) async => tLogId);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.createHabitLog(any()),
      ).thenAnswer((_) async => tLogId);

      final result = await repository.createHabitLog(habitLog: tHabitLog);

      expect(result, const Right(tLogId));
      verify(() => mockLocalDataSource.createHabitLog(any())).called(1);
    });

    test(label('offline: encola para sync'), () async {
      when(
        () => mockLocalDataSource.createHabitLog(any()),
      ).thenAnswer((_) async => tLogId);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockSyncService.markPendingSync(
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.createHabitLog(habitLog: tHabitLog);

      expect(result, const Right(tLogId));
      verify(
        () => mockSyncService.markPendingSync(
          entityType: 'log',
          entityId: any(named: 'entityId'),
          action: 'create',
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test(label('local falla: devuelve Left ServerFailure'), () async {
      when(
        () => mockLocalDataSource.createHabitLog(any()),
      ).thenThrow(Exception('DB error'));

      final result = await repository.createHabitLog(habitLog: tHabitLog);

      expect(result.isLeft(), true);
    });
  });

  group(label('updateHabitLogValue'), () {
    test(label('online + log existe: devuelve Right(null)'), () async {
      when(
        () => mockLocalDataSource.getHabitLogById(any()),
      ).thenAnswer((_) async => tHabitLog);
      when(
        () => mockLocalDataSource.updateHabitLogValue(
          habitId: any(named: 'habitId'),
          logId: any(named: 'logId'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.updateHabitLogValue(
          habitId: any(named: 'habitId'),
          logId: any(named: 'logId'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.updateHabitLogValue(
        habitId: tHabitId,
        logId: tLogId,
        value: 5,
      );

      expect(result, const Right(null));
    });

    test(label('offline + log existe: encola para sync'), () async {
      when(
        () => mockLocalDataSource.getHabitLogById(any()),
      ).thenAnswer((_) async => tHabitLog);
      when(
        () => mockLocalDataSource.updateHabitLogValue(
          habitId: any(named: 'habitId'),
          logId: any(named: 'logId'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockSyncService.markPendingSync(
          entityType: any(named: 'entityType'),
          entityId: any(named: 'entityId'),
          action: any(named: 'action'),
          data: any(named: 'data'),
        ),
      ).thenAnswer((_) async {});

      final result = await repository.updateHabitLogValue(
        habitId: tHabitId,
        logId: tLogId,
        value: 5,
      );

      expect(result, const Right(null));
      verify(
        () => mockSyncService.markPendingSync(
          entityType: 'log',
          entityId: any(named: 'entityId'),
          action: 'update',
          data: any(named: 'data'),
        ),
      ).called(1);
    });

    test(label('log no encontrado: devuelve Left CacheFailure'), () async {
      when(
        () => mockLocalDataSource.getHabitLogById(any()),
      ).thenAnswer((_) async => null);

      final result = await repository.updateHabitLogValue(
        habitId: tHabitId,
        logId: tLogId,
        value: 5,
      );

      expect(result.isLeft(), true);
    });
  });

  group(label('getHabitsByEmail'), () {
    test(label('local hit: devuelve local + sync en background'), () async {
      when(
        () => mockLocalDataSource.getHabitsByUserId(any()),
      ).thenAnswer((_) async => [tHabitEntity]);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockSyncService.syncPendingChanges(),
      ).thenAnswer((_) async => SyncResult(success: 1, failed: 0, errors: []));
      when(
        () => mockRemoteDataSource.getHabitsByUserId(any()),
      ).thenAnswer((_) async => [tHabitEntity]);

      final result = await repository.getHabitsByEmail(tUserId);

      expect(result.length, 1);
      expect(result.first.id, tHabitId);
    });

    test(label('local vacío + online: trae de remote'), () async {
      when(
        () => mockLocalDataSource.getHabitsByUserId(any()),
      ).thenAnswer((_) async => []);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.getHabitsByUserId(any()),
      ).thenAnswer((_) async => [tHabitEntity]);
      when(
        () => mockLocalDataSource.saveHabits(any()),
      ).thenAnswer((_) async {});

      final result = await repository.getHabitsByEmail(tUserId);

      expect(result.length, 1);
      verify(() => mockLocalDataSource.saveHabits(any())).called(1);
    });

    test(label('local vacío + offline: devuelve vacío'), () async {
      when(
        () => mockLocalDataSource.getHabitsByUserId(any()),
      ).thenAnswer((_) async => []);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getHabitsByEmail(tUserId);

      expect(result, isEmpty);
    });
  });

  group(label('getHabitsByEmailPaginated'), () {
    test(label('local hit: devuelve local + sync diferido'), () async {
      when(
        () => mockLocalDataSource.getHabitsByUserIdPaginated(
          userId: any(named: 'userId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => [tHabitEntity]);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockSyncService.syncPendingChanges(),
      ).thenAnswer((_) async => SyncResult(success: 1, failed: 0, errors: []));
      when(
        () => mockRemoteDataSource.getHabitsByUserId(any()),
      ).thenAnswer((_) async => [tHabitEntity]);
      when(
        () => mockLocalDataSource.clearAllHabits(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockLocalDataSource.saveHabits(any()),
      ).thenAnswer((_) async {});

      final result = await repository.getHabitsByEmailPaginated(
        email: tUserId,
        limit: 10,
        offset: 0,
      );

      expect(result.length, 1);
    });

    test(label('local vacío + online: trae y guarda'), () async {
      when(
        () => mockLocalDataSource.getHabitsByUserIdPaginated(
          userId: any(named: 'userId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => []);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemoteDataSource.getHabitsByUserId(any()),
      ).thenAnswer((_) async => [tHabitEntity]);
      when(
        () => mockLocalDataSource.saveHabits(any()),
      ).thenAnswer((_) async {});

      final result = await repository.getHabitsByEmailPaginated(
        email: tUserId,
        limit: 10,
        offset: 0,
      );

      expect(result.length, 1);
    });

    test(label('local vacío + offline: devuelve vacío'), () async {
      when(
        () => mockLocalDataSource.getHabitsByUserIdPaginated(
          userId: any(named: 'userId'),
          limit: any(named: 'limit'),
          offset: any(named: 'offset'),
        ),
      ).thenAnswer((_) async => []);
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.getHabitsByEmailPaginated(
        email: tUserId,
        limit: 10,
        offset: 0,
      );

      expect(result, isEmpty);
    });
  });

  group(label('syncWithRemote'), () {
    test(label('online: delega a sync service'), () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockSyncService.syncPendingChanges(),
      ).thenAnswer((_) async => SyncResult(success: 2, failed: 0, errors: []));
      when(
        () => mockRemoteDataSource.getHabitsByUserId(any()),
      ).thenAnswer((_) async => [tHabitEntity]);
      when(
        () => mockLocalDataSource.clearAllHabits(any()),
      ).thenAnswer((_) async {});
      when(
        () => mockLocalDataSource.saveHabits(any()),
      ).thenAnswer((_) async {});

      final result = await repository.syncWithRemote(tUserId);

      expect(result.success, 2);
    });

    test(label('offline: devuelve resultado con error'), () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);

      final result = await repository.syncWithRemote(tUserId);

      expect(result.success, 0);
      expect(result.failed, 1);
      expect(result.errors.first, contains('Sin conexión'));
    });
  });

  group(label('getPendingSyncCount'), () {
    test(label('delega a sync service'), () async {
      when(() => mockSyncService.getPendingCount()).thenAnswer((_) async => 5);

      final result = await repository.getPendingSyncCount();

      expect(result, 5);
    });
  });
}

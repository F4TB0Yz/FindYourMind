import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:find_your_mind/core/database/app_database.dart';
import 'package:find_your_mind/core/services/sync_service.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockHabitsRemoteDataSource extends Mock implements HabitsRemoteDataSource {}

void main() {
  late AppDatabase db;
  late MockHabitsRemoteDataSource mockRemoteDataSource;
  late SyncService syncService;

  setUpAll(() {
    registerFallbackValue(
      HabitEntity(
        id: 'fallback-habit',
        userId: 'fallback-user',
        title: 'Fallback',
        description: 'Fallback',
        icon: 'icon',
        category: HabitCategory.none,
        trackingType: HabitTrackingType.single,
        targetValue: 1,
        initialDate: '2025-01-01',
        logs: const [],
      ),
    );
    registerFallbackValue(
      HabitLog(
        id: 'fallback-log',
        habitId: 'fallback-habit',
        date: '2025-01-01',
        value: 1,
      ),
    );
  });

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    mockRemoteDataSource = MockHabitsRemoteDataSource();
    syncService = SyncService(
      dbHelper: db,
      remoteDataSource: mockRemoteDataSource,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('SyncService Retry Policy', () {
    final String fullHabitJson = jsonEncode({
      'id': '1',
      'user_id': 'u1',
      'title': 'Test',
      'description': 'Desc',
      'icon': 'icon',
      'category': 'none',
      'tracking_type': 'single',
      'target_value': 1,
      'initial_date': DateTime.now().toIso8601String(),
    });

    test('should include items with retryCount < maxRetryCount', () async {
      // Arrange
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: '1',
              actionType: 'create',
              data: fullHabitJson,
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(0),
            ),
          );

      registerFallbackValue(
        HabitEntity(
          id: '1',
          userId: 'u1',
          title: 'Test',
          description: '',
          icon: '',
          category: HabitCategory.none,
          trackingType: HabitTrackingType.single,
          targetValue: 1,
          initialDate: DateTime.now().toIso8601String(),
          logs: const [],
        ),
      );

      when(() => mockRemoteDataSource.createHabit(any()))
          .thenAnswer((_) async => 'remote_1');

      // Act
      final result = await syncService.syncPendingChanges();

      // Assert
      expect(result.success, 1);
      final pending = await db.select(db.pendingSyncTable).get();
      expect(pending.isEmpty, true);
    });

    test('should exclude items with retryCount >= maxRetryCount', () async {
      // Arrange
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: '1',
              actionType: 'create',
              data: fullHabitJson,
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(SyncService.maxRetryCount),
            ),
          );

      // Act
      final result = await syncService.syncPendingChanges();

      // Assert
      expect(result.success, 0);
      expect(result.failed, 0);
      final pending = await db.select(db.pendingSyncTable).get();
      expect(pending.length, 1);
    });

    test('should increment retryCount on failure', () async {
      // Arrange
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: '1',
              actionType: 'create',
              data: fullHabitJson,
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(0),
            ),
          );

      when(() => mockRemoteDataSource.createHabit(any()))
          .thenAnswer((_) async => null); // Failure

      // Act
      await syncService.syncPendingChanges();

      // Assert
      final pending = await db.select(db.pendingSyncTable).getSingle();
      expect(pending.retryCount, 1);
    });

    test('should increment retryCount on exception', () async {
      // Arrange
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: '1',
              actionType: 'create',
              data: fullHabitJson,
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(0),
            ),
          );

      when(() => mockRemoteDataSource.createHabit(any()))
          .thenThrow(Exception('Network error'));

      // Act
      await syncService.syncPendingChanges();

      // Assert
      final pending = await db.select(db.pendingSyncTable).getSingle();
      expect(pending.retryCount, 1);
    });

    test('getFailedItems returns only items with retryCount >= maxRetryCount', () async {
      // Arrange
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: '1',
              actionType: 'create',
              data: '{}',
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(0),
            ),
          );
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: '2',
              actionType: 'create',
              data: '{}',
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(SyncService.maxRetryCount),
            ),
          );

      // Act
      final failed = await syncService.getFailedItems();

      // Assert
      expect(failed.length, 1);
      expect(failed.first.entityId, '2');
    });

    test('purgeFailedItems removes only items with retryCount >= maxRetryCount', () async {
      // Arrange
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: '1',
              actionType: 'create',
              data: '{}',
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(0),
            ),
          );
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: '2',
              actionType: 'create',
              data: '{}',
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(SyncService.maxRetryCount),
            ),
          );

      // Act
      await syncService.purgeFailedItems();

      // Assert
      final remaining = await db.select(db.pendingSyncTable).get();
      expect(remaining.length, 1);
      expect(remaining.first.entityId, '1');
    });
  });

  group('markPendingSync', () {
    test('inserts new pending sync item', () async {
      await syncService.markPendingSync(
        entityType: 'habit',
        entityId: 'h1',
        action: 'create',
        data: {'id': 'h1', 'title': 'Test'},
      );

      final pending = await db.select(db.pendingSyncTable).get();
      expect(pending.length, 1);
      expect(pending.first.entityId, 'h1');
      expect(pending.first.actionType, 'create');
    });

    test('upserts when entity already pending', () async {
      await syncService.markPendingSync(
        entityType: 'habit',
        entityId: 'h1',
        action: 'create',
        data: {'id': 'h1', 'title': 'Test'},
      );

      await syncService.markPendingSync(
        entityType: 'habit',
        entityId: 'h1',
        action: 'update',
        data: {'id': 'h1', 'title': 'Updated'},
      );

      final pending = await db.select(db.pendingSyncTable).get();
      expect(pending.length, 1);
      expect(pending.first.actionType, 'update');
    });
  });

  group('syncPendingChanges full flow', () {
    test('habit create success: removes from queue', () async {
      final habitJson = jsonEncode({
        'id': 'h1',
        'user_id': 'u1',
        'title': 'Test',
        'description': 'Desc',
        'icon': 'icon',
        'category': 'none',
        'tracking_type': 'single',
        'target_value': 1,
        'initial_date': '2025-01-01',
      });

      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: 'h1',
              actionType: 'create',
              data: habitJson,
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(0),
            ),
          );

      when(() => mockRemoteDataSource.createHabit(any()))
          .thenAnswer((_) async => 'h1');

      final result = await syncService.syncPendingChanges();

      expect(result.success, 1);
      final pending = await db.select(db.pendingSyncTable).get();
      expect(pending.isEmpty, true);
    });

    test('habit update success', () async {
      final habitJson = jsonEncode({
        'id': 'h1',
        'user_id': 'u1',
        'title': 'Updated',
        'description': 'Desc',
        'icon': 'icon',
        'category': 'none',
        'tracking_type': 'single',
        'target_value': 1,
        'initial_date': '2025-01-01',
      });

      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: 'h1',
              actionType: 'update',
              data: habitJson,
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(0),
            ),
          );

      when(() => mockRemoteDataSource.updateHabit(any()))
          .thenAnswer((_) async {});

      final result = await syncService.syncPendingChanges();

      expect(result.success, 1);
    });

    test('habit delete success', () async {
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: 'h1',
              actionType: 'delete',
              data: '{"id": "h1"}',
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(0),
            ),
          );

      when(() => mockRemoteDataSource.deleteHabit(any()))
          .thenAnswer((_) async {});

      final result = await syncService.syncPendingChanges();

      expect(result.success, 1);
      final pending = await db.select(db.pendingSyncTable).get();
      expect(pending.isEmpty, true);
    });

    test('log create success', () async {
      final logJson = jsonEncode({
        'id': 'l1',
        'habit_id': 'h1',
        'date': '2025-01-15',
        'value': 1,
      });

      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'log',
              entityId: 'l1',
              actionType: 'create',
              data: logJson,
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(0),
            ),
          );

      when(() => mockRemoteDataSource.createHabitLog(any()))
          .thenAnswer((_) async => 'l1');

      final result = await syncService.syncPendingChanges();

      expect(result.success, 1);
    });

    test('log update success', () async {
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'log',
              entityId: 'l1',
              actionType: 'update',
              data: '{"id": "l1", "habit_id": "h1", "value": 5}',
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(0),
            ),
          );

      when(() => mockRemoteDataSource.updateHabitLogValue(
        habitId: any(named: 'habitId'),
        logId: any(named: 'logId'),
        value: any(named: 'value'),
      )).thenAnswer((_) async {});

      final result = await syncService.syncPendingChanges();

      expect(result.success, 1);
    });
  });

  group('dependency chain', () {
    test('habit create fails: logs blocked (retryCount incremented)', () async {
      final habitJson = jsonEncode({
        'id': 'h1',
        'user_id': 'u1',
        'title': 'Test',
      });
      final logJson = jsonEncode({
        'id': 'l1',
        'habit_id': 'h1',
        'date': '2025-01-15',
        'value': 1,
      });

      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: 'h1',
              actionType: 'create',
              data: habitJson,
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(0),
            ),
          );
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'log',
              entityId: 'l1',
              actionType: 'create',
              data: logJson,
              createdAt: DateTime.now().toIso8601String(),
              retryCount: const Value(0),
            ),
          );

      when(() => mockRemoteDataSource.createHabit(any()))
          .thenThrow(Exception('Remote error'));

      await syncService.syncPendingChanges();

      final pending = await db.select(db.pendingSyncTable).get();
      expect(pending.length, 2);
      final habitPending = pending.firstWhere((p) => p.entityType == 'habit');
      expect(habitPending.retryCount, 1);
    });
  });

  group('clearPendingSync', () {
    test('clears entire queue', () async {
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: 'h1',
              actionType: 'create',
              data: '{}',
              createdAt: DateTime.now().toIso8601String(),
            ),
          );
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'log',
              entityId: 'l1',
              actionType: 'create',
              data: '{}',
              createdAt: DateTime.now().toIso8601String(),
            ),
          );

      await syncService.clearPendingSync();

      final pending = await db.select(db.pendingSyncTable).get();
      expect(pending.isEmpty, true);
    });
  });

group('getPendingCount', () {
    test('returns correct count', () async {
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: 'h1',
              actionType: 'create',
              data: '{}',
              createdAt: DateTime.now().toIso8601String(),
            ),
          );
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'log',
              entityId: 'l1',
              actionType: 'create',
              data: '{}',
              createdAt: DateTime.now().toIso8601String(),
            ),
          );

      final count = await syncService.getPendingCount();

      expect(count, 2);
    });

    test('returns 0 when empty', () async {
      final count = await syncService.getPendingCount();

      expect(count, 0);
    });
  });

  group('FIFO ordering', () {
    test('syncs items in createdAt ASC order regardless of insert order', () async {
      final earlierTime = DateTime(2025, 1, 1, 10, 0);
      final laterTime = DateTime(2025, 1, 1, 11, 0);

      final habitLaterJson = jsonEncode({
        'id': 'h2',
        'user_id': 'u1',
        'title': 'Later',
        'description': '',
        'icon': 'icon',
        'category': 'none',
        'tracking_type': 'single',
        'target_value': 1,
        'initial_date': '2025-01-01',
      });

      final habitEarlierJson = jsonEncode({
        'id': 'h1',
        'user_id': 'u1',
        'title': 'Earlier',
        'description': '',
        'icon': 'icon',
        'category': 'none',
        'tracking_type': 'single',
        'target_value': 1,
        'initial_date': '2025-01-01',
      });

      // Insert later item first in DB
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: 'h2',
              actionType: 'create',
              data: habitLaterJson,
              createdAt: laterTime.toIso8601String(),
              retryCount: const Value(0),
            ),
          );

      // Insert earlier item second in DB
      await db.into(db.pendingSyncTable).insert(
            PendingSyncTableCompanion.insert(
              entityType: 'habit',
              entityId: 'h1',
              actionType: 'create',
              data: habitEarlierJson,
              createdAt: earlierTime.toIso8601String(),
              retryCount: const Value(0),
            ),
          );

      final callOrder = <String>[];
      when(() => mockRemoteDataSource.createHabit(any())).thenAnswer((inv) async {
        final habit = inv.positionalArguments[0] as HabitEntity;
        callOrder.add(habit.id);
        return habit.id;
      });

      await syncService.syncPendingChanges();

      expect(callOrder, ['h1', 'h2']);
    });
  });
}

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
}

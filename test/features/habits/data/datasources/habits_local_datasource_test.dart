import 'package:drift/native.dart';
import 'package:find_your_mind/core/database/app_database.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_local_datasource.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late HabitsLocalDatasourceImpl datasource;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    datasource = HabitsLocalDatasourceImpl(databaseHelper: db);
  });

  tearDown(() async {
    await db.close();
  });

  final tHabit = HabitEntity(
    id: 'h1',
    userId: 'u1',
    title: 'Test Habit',
    description: 'Description',
    icon: 'icon',
    category: HabitCategory.health,
    trackingType: HabitTrackingType.single,
    targetValue: 1,
    initialDate: '2026-04-29',
    logs: const [],
  );

  final tLog = HabitLog(
    id: 'l1',
    habitId: 'h1',
    date: '2026-04-29',
    value: 1,
  );

  group('HabitsLocalDatasourceImpl', () {
    test('createHabit should insert habit into database', () async {
      final result = await datasource.createHabit(tHabit);
      expect(result, 'h1');

      final habits = await datasource.getHabitsByUserId('u1');
      expect(habits.length, 1);
      expect(habits.first.id, 'h1');
      expect(habits.first.title, 'Test Habit');
    });

    test('getHabitsByUserId should return habits with their logs', () async {
      await datasource.createHabit(tHabit);
      await datasource.createHabitLog(tLog);

      final habits = await datasource.getHabitsByUserId('u1');
      expect(habits.length, 1);
      expect(habits.first.logs.length, 1);
      expect(habits.first.logs.first.id, 'l1');
    });

    test('createHabitLog should not insert duplicate logs for same habit/date', () async {
      await datasource.createHabit(tHabit);
      final id1 = await datasource.createHabitLog(tLog);
      
      final duplicateLog = HabitLog(
        id: 'l2',
        habitId: 'h1',
        date: '2026-04-29',
        value: 1,
      );
      final id2 = await datasource.createHabitLog(duplicateLog);

      expect(id1, 'l1');
      expect(id2, 'l1'); // Should return existing id

      final habits = await datasource.getHabitsByUserId('u1');
      expect(habits.first.logs.length, 1);
    });

    test('updateHabitLogValue should update log and reset synced flag', () async {
      await datasource.createHabit(tHabit);
      await datasource.createHabitLog(tLog);

      await datasource.updateHabitLogValue(
        habitId: 'h1',
        logId: 'l1',
        value: 5,
      );

      final habits = await datasource.getHabitsByUserId('u1');
      expect(habits.first.logs.first.value, 5);
      
      final logRow = await db.select(db.habitLogsTable).getSingle();
      expect(logRow.synced, 0);
    });

    test('deleteHabit should remove habit and its logs (cascade)', () async {
      await datasource.createHabit(tHabit);
      await datasource.createHabitLog(tLog);

      await datasource.deleteHabit('h1');

      final habits = await datasource.getHabitsByUserId('u1');
      expect(habits.isEmpty, true);

      final logs = await db.select(db.habitLogsTable).get();
      expect(logs.isEmpty, true);
    });

    test('saveHabits should perform batch upsert and set synced=1', () async {
      final habitsToSave = [
        tHabit.copyWith(logs: [tLog]),
      ];

      await datasource.saveHabits(habitsToSave);

      final habits = await datasource.getHabitsByUserId('u1');
      expect(habits.length, 1);
      expect(habits.first.logs.length, 1);

      final habitRow = await db.select(db.habitsTable).getSingle();
      expect(habitRow.synced, 1);

      final logRow = await db.select(db.habitLogsTable).getSingle();
      expect(logRow.synced, 1);
    });
  });
}

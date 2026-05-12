import 'package:drift/native.dart';
import 'package:find_your_mind/core/database/app_database.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_local_datasource.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_utils/test_output_style.dart';

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

  const tHabit = HabitEntity(
    id: 'h1',
    userId: 'u1',
    title: 'Test Habit',
    description: 'Description',
    icon: 'icon',
    category: HabitCategory.health,
    trackingType: HabitTrackingType.single,
    targetValue: 1,
    initialDate: '2026-04-29',
    logs: [],
  );

  const tLog = HabitLog(id: 'l1', habitId: 'h1', date: '2026-04-29', value: 1);

  group(label('HabitsLocalDatasourceImpl'), () {
    test(label('createHabit inserta hábito en DB'), () async {
      final result = await datasource.createHabit(tHabit);
      expect(result, 'h1');

      final habits = await datasource.getHabitsByUserId('u1');
      expect(habits.length, 1);
      expect(habits.first.id, 'h1');
      expect(habits.first.title, 'Test Habit');
    });

    test(label('getHabitsByUserId devuelve hábitos con sus logs'), () async {
      await datasource.createHabit(tHabit);
      await datasource.createHabitLog(tLog);

      final habits = await datasource.getHabitsByUserId('u1');
      expect(habits.length, 1);
      expect(habits.first.logs.length, 1);
      expect(habits.first.logs.first.id, 'l1');
    });

    test(
      label('createHabitLog no inserta logs duplicados para mismo hábito/fecha'),
      () async {
        await datasource.createHabit(tHabit);
        final id1 = await datasource.createHabitLog(tLog);

        const duplicateLog = HabitLog(
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
      },
    );

    test(label('updateHabitLogValue actualiza log'), () async {
      await datasource.createHabit(tHabit);
      await datasource.createHabitLog(tLog);

      await datasource.updateHabitLogValue(
        habitId: 'h1',
        logId: 'l1',
        value: 5,
      );

      final habits = await datasource.getHabitsByUserId('u1');
      expect(habits.first.logs.first.value, 5);

      // No more 'synced' column; ensure value updated
    });

    test(label('deleteHabit elimina hábito y sus logs (cascade)'), () async {
      await datasource.createHabit(tHabit);
      await datasource.createHabitLog(tLog);

      await datasource.deleteHabit('h1');

      final habits = await datasource.getHabitsByUserId('u1');
      expect(habits.isEmpty, true);

      final logs = await db.select(db.habitLogsTable).get();
      expect(logs.isEmpty, true);
    });

    test(label('saveHabits hace upsert en batch'), () async {
      final habitsToSave = [
        tHabit.copyWith(logs: [tLog]),
      ];

      await datasource.saveHabits(habitsToSave);

      final habits = await datasource.getHabitsByUserId('u1');
      expect(habits.length, 1);
      expect(habits.first.logs.length, 1);

      // No 'synced' column to assert on
      // No 'synced' column to assert on
    });
  });
}

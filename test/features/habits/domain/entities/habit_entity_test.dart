import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:flutter_test/flutter_test.dart';

String _dateDaysAgo(int daysAgo) {
  final now = DateTime.now();
  final date = DateTime(now.year, now.month, now.day).subtract(
    Duration(days: daysAgo),
  );

  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

void main() {
  test('computes one-time habit metrics from logs', () {
    final habit = HabitEntity(
      id: 'habit-1',
      userId: 'user-1',
      title: 'Morning Run',
      description: 'Run once per day',
      icon: '🏃',
      category: HabitCategory.health,
      trackingType: HabitTrackingType.single,
      targetValue: 1,
      initialDate: _dateDaysAgo(6),
      logs: [
        HabitLog(id: '1', habitId: 'habit-1', date: _dateDaysAgo(6), value: 1),
        HabitLog(id: '2', habitId: 'habit-1', date: _dateDaysAgo(5), value: 1),
        HabitLog(id: '3', habitId: 'habit-1', date: _dateDaysAgo(4), value: 1),
        HabitLog(id: '4', habitId: 'habit-1', date: _dateDaysAgo(2), value: 1),
        HabitLog(id: '5', habitId: 'habit-1', date: _dateDaysAgo(1), value: 1),
      ],
    );

    expect(habit.completedDaysCount, 5);
    expect(habit.longestStreak, 3);
    expect(habit.streak, 2);
    expect(habit.completionRate, closeTo(71.428, 0.001));
  });
}
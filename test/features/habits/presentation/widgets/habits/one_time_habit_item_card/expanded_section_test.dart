import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/one_time_habit_item_card/expanded_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

String _dateDaysAgo(int daysAgo) {
  final now = DateTime.now();
  final date = DateTime(now.year, now.month, now.day).subtract(
    Duration(days: daysAgo),
  );

  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

void main() {
  testWidgets('renders real one-time habit metrics when expanded', (tester) async {
    final habit = HabitEntity(
      id: 'habit-1',
      userId: 'user-1',
      title: 'Morning Run',
      description: 'Run once per day',
      icon: '🏃',
      category: HabitCategory.health,
      trackingType: HabitTrackingType.single,
      targetValue: 1,
      initialDate: _dateDaysAgo(5),
      logs: [
        HabitLog(id: '1', habitId: 'habit-1', date: _dateDaysAgo(5), value: 1),
        HabitLog(id: '2', habitId: 'habit-1', date: _dateDaysAgo(4), value: 1),
        HabitLog(id: '3', habitId: 'habit-1', date: _dateDaysAgo(3), value: 1),
        HabitLog(id: '4', habitId: 'habit-1', date: _dateDaysAgo(1), value: 1),
        HabitLog(id: '5', habitId: 'habit-1', date: _dateDaysAgo(0), value: 1),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ExpandedSection(
            isExpanded: true,
            habit: habit,
            cardFillColor: const Color(0xFF24424F),
            expandedSectionFillColor: const Color(0xFF16313B),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('RACHA'), findsOneWidget);
    expect(find.text('MEJOR'), findsOneWidget);
    expect(find.text('CUMPLIDO'), findsOneWidget);
    expect(find.text('${habit.streak}d'), findsOneWidget);
    expect(find.text('${habit.longestStreak}d'), findsOneWidget);
    expect(
      find.text('${habit.completedDaysCount}/${habit.daysSinceStart + 1}'),
      findsOneWidget,
    );
  });
}
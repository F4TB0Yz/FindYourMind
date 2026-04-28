import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WeeklyHabitsStatistics extends StatelessWidget {
  const WeeklyHabitsStatistics({super.key});

  static const List<String> _weekLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
  static const int _pillRows = 4;

  @override
  Widget build(BuildContext context) {
    final int todayIndex = DateTime.now().weekday - 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_weekLabels.length, (index) {
          return _WeekDayColumn(
            label: _weekLabels[index],
            dayIndex: index,
            isToday: index == todayIndex,
          );
        }),
      ),
    );
  }
}

class _WeekDayColumn extends StatelessWidget {
  final String label;
  final int dayIndex;
  final bool isToday;

  const _WeekDayColumn({
    required this.label,
    required this.dayIndex,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color labelColor =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: isToday ? FontWeight.w900 : FontWeight.w600,
                      color: isToday ? const Color(0xFF155e75) : labelColor,
                    ),
              ),
            ),
            ...List.generate(WeeklyHabitsStatistics._pillRows, (rowIndex) {
              return _WeeklyPill(
                dayIndex: dayIndex,
                rowIndex: rowIndex,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _WeeklyPill extends StatelessWidget {
  final int dayIndex;
  final int rowIndex;

  const _WeeklyPill({
    required this.dayIndex,
    required this.rowIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<HabitsProvider, bool>(
      selector: (_, provider) {
        final int completedHabits =
            provider.weeklyHabitsStatsSummary.completedHabitsByDay[dayIndex];
        return rowIndex < completedHabits;
      },
      builder: (context, isActive, _) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final Color inactivePillColor = isDark
            ? Colors.white.withValues(alpha: 0.14)
            : const Color.fromARGB(255, 177, 185, 193);

        return Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              gradient: isActive
                  ? const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF187290),
                        Color(0xFF1fc067),
                      ],
                    )
                  : null,
              color: isActive ? null : inactivePillColor,
            ),
          ),
        );
      },
    );
  }
}

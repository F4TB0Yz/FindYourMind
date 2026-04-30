import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:flutter/material.dart';

class StatisticsHabit extends StatelessWidget {
  final HabitEntity habit;

  const StatisticsHabit({super.key, required this.habit});

  int _completedDaysCount() {
    int count = 0;
    for (final log in habit.logs) {
      if (log.value >= habit.targetValue) {
        count++;
      }
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final totalDays = habit.daysSinceStart + 1;
    final completedDays = _completedDaysCount();
    final successRate = totalDays > 0
        ? (completedDays / totalDays * 100).toStringAsFixed(1)
        : '0.0';
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Días totales', value: '$totalDays'),
          _StatDivider(),
          _StatItem(label: 'Cumplidos', value: '$completedDays'),
          _StatDivider(),
          _StatItem(label: 'Éxito', value: '$successRate%'),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: cs.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
  }
}

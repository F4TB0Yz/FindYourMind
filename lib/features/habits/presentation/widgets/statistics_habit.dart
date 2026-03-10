import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:flutter/material.dart';

/// Widget de estadísticas del hábito: días totales, cumplidos y tasa de éxito.
class StatisticsHabit extends StatelessWidget {
  final HabitEntity habit;

  const StatisticsHabit({super.key, required this.habit});

  int _completedDaysCount() {
    int count = 0;
    for (final progress in habit.progress) {
      if (progress.dailyCounter >= habit.dailyGoal) count++;
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Días totales', value: '$totalDays'),
              _StatDivider(),
              _StatItem(label: 'Cumplidos', value: '$completedDays'),
              _StatDivider(),
              _StatItem(label: 'Éxito', value: '$successRate%'),
            ],
          ),
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
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.accentText,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
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
      color: AppColors.borderSubtle,
    );
  }
}
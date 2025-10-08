import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:flutter/material.dart';

class StatisticsHabit extends StatelessWidget {
  final HabitEntity habit;

  const StatisticsHabit({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final totalDays = habit.daysSinceStart + 1;
    final completedDays = _getCompletedDaysCount();
    final successRate = totalDays > 0 ? (completedDays / totalDays * 100).toStringAsFixed(1) : '0.0';

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estadísticas',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Días totales', '$totalDays'),
              _buildStatItem('Días cumplidos', '$completedDays'),
              _buildStatItem('Tasa éxito', '$successRate%'),
            ],
          ),
        ],
      ),
    );
  }

  int _getCompletedDaysCount() {
    int count = 0;
    for (var progress in habit.progress) {
      if (progress.dailyCounter >= habit.dailyGoal) {
        count++;
      }
    }
    return count;
  }

   Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD1F312),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white38,
          ),
        ),
      ],
    );
  }
}
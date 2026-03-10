import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/statistics_habit.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/weekly_progress/weekly_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DetailsView extends StatelessWidget {
  final HabitEntity habit;

  const DetailsView({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Icono gigante (opcional, centrado como hero visual)
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: SvgPicture.asset(
              habit.icon,
              width: 64,
              height: 64,
            ),
          ),
        ),
        
        const SizedBox(height: 36),

        const Text(
          'Progreso Semanal',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        WeeklyProgress(habit: habit),

        const SizedBox(height: 36),

        const Text(
          'Estadísticas',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        StatisticsHabit(habit: habit),

        const SizedBox(height: 48), // Espacio extra al fondo
      ],
    );
  }
}
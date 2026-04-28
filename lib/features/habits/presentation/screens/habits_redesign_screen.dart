import 'package:find_your_mind/features/habits/presentation/widgets/weekly_habits_statistics.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/one_time_habit_item_card.dart';
import 'package:find_your_mind/shared/presentation/widgets/layouts/feature_layout.dart';
import 'package:flutter/material.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/today_progress_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HabitsRedesignScreen extends StatelessWidget {
  const HabitsRedesignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureLayout(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TodayProgressCard(),

                // Vista estadisticas
                WeeklyHabitsStatistics(),

                SizedBox(height: 8),

                _HabitsSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitsSection extends StatelessWidget {
  const _HabitsSection();

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tus Hábitos",
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFFecfeff).withValues(alpha: 0.72)
                      : const Color(0xFF15B0B8).withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.plus,
                      size: 18,
                      color: Color(0xFF155e75),
                    ),

                    const SizedBox(width: 4),

                    Text(
                      "Nuevo",
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF155e75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Lista de hábitos
        const OneTimeHabitItemCard(
          emoji: '🛏️',
          title: 'Tender cama',
          description: 'Cada mañana al despertar',
          streakDays: 1,
          cardColor: Color(0xFFDFFECF),
        ),
        const OneTimeHabitItemCard(
          emoji: '💧',
          title: 'Tomar agua',
          description: '1 vaso antes de salir de casa',
          streakDays: 3,
          cardColor: Color(0xFFD6F5FF),
        ),
        const OneTimeHabitItemCard(
          emoji: '🧘',
          title: 'Respirar 2 minutos',
          description: 'Al iniciar jornada',
          streakDays: 5,
          cardColor: Color(0xFFE8D8FF),
        ),
        const OneTimeHabitItemCard(
          emoji: '📚',
          title: 'Leer 10 paginas',
          description: 'Antes de dormir',
          streakDays: 2,
          cardColor: Color(0xFFFFE4CC),
        ),
        const OneTimeHabitItemCard(
          emoji: '🚶',
          title: 'Caminar',
          description: 'Despues de almuerzo',
          streakDays: 4,
          cardColor: Color(0xFFFFD9E6),
        ),
      ],
    );
  }
}

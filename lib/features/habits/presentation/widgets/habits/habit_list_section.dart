import 'package:find_your_mind/config/theme/app_text_styles.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/habit_card_wrapper/habit_card_wrapper.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/habit_section_header.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HabitListSection extends StatelessWidget {
  const HabitListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HabitsProvider>();
    final habits = provider.habits;
    final hasVisible = provider.visibleHabitCount > 0;

    return Column(
      children: [
        const HabitSectionHeader(),
        const SizedBox(height: 12),
        if (!hasVisible && habits.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Text(
              'No hay hábitos para este filtro.',
              style: AppTextStyles.bodySmall(context),
            ),
          ),
        if (habits.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Text(
              'Aún no tienes hábitos.',
              style: AppTextStyles.bodySmall(context),
            ),
          ),
        ListView.builder(
          itemCount: habits.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final habit = habits[index];
            return HabitCardWrapper(key: ValueKey(habit.id), habit: habit);
          },
        ),
      ],
    );
  }
}
import 'package:find_your_mind/config/theme/app_text_styles.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_button.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/habit_filter_bar.dart';
import 'package:flutter/material.dart';

class HabitSectionHeader extends StatelessWidget {
  const HabitSectionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Tus hábitos', style: AppTextStyles.titleLarge(context)),
          const HabitFilterBar(),
          const CreateHabitButton(),
        ],
      ),
    );
  }
}
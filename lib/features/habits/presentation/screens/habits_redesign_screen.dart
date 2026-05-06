import 'package:find_your_mind/features/habits/presentation/widgets/habits/habit_list_section.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/today_progress_card.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/weekly_habits_statistics.dart';
import 'package:find_your_mind/shared/presentation/widgets/layouts/feature_layout.dart';
import 'package:flutter/material.dart';

class HabitsRedesignScreen extends StatelessWidget {
  const HabitsRedesignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureLayout(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TodayProgressCard(),
            WeeklyHabitsStatistics(),
            SizedBox(height: 8),
            HabitListSection(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
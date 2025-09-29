import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DailyGoalCounter extends StatelessWidget {
  const DailyGoalCounter({super.key});

  @override
  Widget build(BuildContext context) {
    NewHabitProvider newHabitProvider = Provider.of<NewHabitProvider>(context);

    return  Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => {
            newHabitProvider.setDailyGoal(newHabitProvider.dailyGoal - 1) 
          },
          icon: const Icon(Icons.remove)
        ),

        Text(
          newHabitProvider.dailyGoal.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white
          ),
        ),

        IconButton(
          onPressed: () => {
            newHabitProvider.setDailyGoal(newHabitProvider.dailyGoal + 1)
          },
          icon: const Icon(Icons.add)
        ),
      ],
    );
  }
}
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DailyGoalCounter extends StatelessWidget {
  final int? initialValue;
  final ValueChanged<int>? onChanged;
  final bool useProvider;

  const DailyGoalCounter({
    super.key,
    this.initialValue,
    this.onChanged,
    this.useProvider = true,
  });

  @override
  Widget build(BuildContext context) {
    // Si useProvider es true, usa el NewHabitProvider (para crear hábitos)
    // Si es false, usa el valor local (para editar hábitos)
    if (useProvider) {
      return _buildWithProvider(context);
    } else {
      return _buildWithLocalState(context);
    }
  }

  Widget _buildWithProvider(BuildContext context) {
    NewHabitProvider newHabitProvider = Provider.of<NewHabitProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            if (newHabitProvider.dailyGoal > 1) {
              newHabitProvider.setDailyGoal(newHabitProvider.dailyGoal - 1);
            }
          },
          icon: const Icon(Icons.remove),
          iconSize: 52,
        ),
        Text(
          newHabitProvider.dailyGoal.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            newHabitProvider.setDailyGoal(newHabitProvider.dailyGoal + 1);
          },
          icon: const Icon(Icons.add),
          iconSize: 52,
        ),
      ],
    );
  }

  Widget _buildWithLocalState(BuildContext context) {
    final int currentValue = initialValue ?? 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            if (currentValue > 1 && onChanged != null) {
              onChanged!(currentValue - 1);
            }
          },
          icon: const Icon(Icons.remove),
          iconSize: 52,
        ),
        Text(
          currentValue.toString(),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            if (onChanged != null) {
              onChanged!(currentValue + 1);
            }
          },
          icon: const Icon(Icons.add),
          iconSize: 52,
        ),
      ],
    );
  }
}
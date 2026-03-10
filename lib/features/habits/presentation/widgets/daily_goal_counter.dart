import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Control numérico para configurar la meta diaria de un hábito.
///
/// Puede operar con el [NewHabitProvider] (pantalla de creación) o con
/// un valor local y callback [onChanged] (pantalla de edición).
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
    if (useProvider) {
      final provider = Provider.of<NewHabitProvider>(context);
      return _CounterLayout(
        value: provider.dailyGoal,
        onDecrement: provider.dailyGoal > 1
            ? () => provider.setDailyGoal(provider.dailyGoal - 1)
            : null,
        onIncrement: () => provider.setDailyGoal(provider.dailyGoal + 1),
      );
    }

    final currentValue = initialValue ?? 1;
    return _CounterLayout(
      value: currentValue,
      onDecrement: currentValue > 1 && onChanged != null
          ? () => onChanged!(currentValue - 1)
          : null,
      onIncrement: onChanged != null ? () => onChanged!(currentValue + 1) : null,
    );
  }
}

/// Layout del contador: botón menos, valor, botón más.
class _CounterLayout extends StatelessWidget {
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _CounterLayout({
    required this.value,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderSubtle, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CounterButton(
            icon: Icons.remove,
            onTap: onDecrement,
          ),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          _CounterButton(
            icon: Icons.add,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

/// Botón de incremento o decremento del contador.
class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null ? AppColors.textSecondary : AppColors.textMuted,
        ),
      ),
    );
  }
}
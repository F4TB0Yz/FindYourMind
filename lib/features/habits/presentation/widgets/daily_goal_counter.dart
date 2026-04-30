import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';

class DailyGoalCounter extends StatelessWidget {
  final int? initialValue;
  final ValueChanged<int>? onChanged;
  final bool useProvider;
  final HabitTrackingType? trackingType;

  const DailyGoalCounter({
    super.key,
    this.initialValue,
    this.onChanged,
    this.useProvider = true,
    this.trackingType,
  });

  int _stepFor(HabitTrackingType type) {
    return switch (type) {
      HabitTrackingType.single => 1,
      HabitTrackingType.timed => 60,
      HabitTrackingType.counter => 1,
    };
  }

  String _labelFor(HabitTrackingType type, int value) {
    return switch (type) {
      HabitTrackingType.single => '1 vez',
      HabitTrackingType.counter => '$value repeticiones',
      HabitTrackingType.timed => '${value ~/ 60} min',
    };
  }

  @override
  Widget build(BuildContext context) {
    if (useProvider) {
      final provider = Provider.of<NewHabitProvider>(context);
      final step = _stepFor(provider.trackingType);
      final isSingle = provider.trackingType == HabitTrackingType.single;

      return _CounterLayout(
        valueLabel: _labelFor(provider.trackingType, provider.targetValue),
        onDecrement: !isSingle && provider.targetValue > step
            ? () => provider.setTargetValue(provider.targetValue - step)
            : null,
        onIncrement: isSingle
            ? null
            : () => provider.setTargetValue(provider.targetValue + step),
      );
    }

    final type = trackingType ?? HabitTrackingType.counter;
    final currentValue = initialValue ?? 1;
    final step = _stepFor(type);
    final isSingle = type == HabitTrackingType.single;

    return _CounterLayout(
      valueLabel: _labelFor(type, currentValue),
      onDecrement: !isSingle && currentValue > step && onChanged != null
          ? () => onChanged!(currentValue - step)
          : null,
      onIncrement: !isSingle && onChanged != null
          ? () => onChanged!(currentValue + step)
          : null,
    );
  }
}

class _CounterLayout extends StatelessWidget {
  final String valueLabel;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _CounterLayout({
    required this.valueLabel,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _CounterButton(
            icon: HugeIcons.strokeRoundedMinusSign,
            onTap: onDecrement,
          ),
          Text(
            valueLabel,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
          ),
          _CounterButton(
            icon: HugeIcons.strokeRoundedAdd01,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final List<List<dynamic>> icon;
  final VoidCallback? onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: HugeIcon(
          icon: icon,
          size: 20,
          color: onTap != null ? cs.onSurfaceVariant : cs.outline,
        ),
      ),
    );
  }
}

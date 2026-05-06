import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/animated_filter_chip.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HabitFilterBar extends StatelessWidget {
  const HabitFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final activeFilter = context.select<HabitsProvider, HabitFilter>(
      (p) => p.activeFilter,
    );
    final provider = context.read<HabitsProvider>();

    return Row(
      children: [
        AnimatedFilterChip(
          label: 'Todos',
          isActive: activeFilter == HabitFilter.todos,
          onTap: () => provider.setFilter(HabitFilter.todos),
        ),
        const SizedBox(width: 4),
        AnimatedFilterChip(
          label: 'Completos',
          isActive: activeFilter == HabitFilter.completados,
          onTap: () => provider.setFilter(HabitFilter.completados),
        ),
        const SizedBox(width: 4),
        AnimatedFilterChip(
          label: 'Incompletos',
          isActive: activeFilter == HabitFilter.incompletos,
          onTap: () => provider.setFilter(HabitFilter.incompletos),
        ),
      ],
    );
  }
}
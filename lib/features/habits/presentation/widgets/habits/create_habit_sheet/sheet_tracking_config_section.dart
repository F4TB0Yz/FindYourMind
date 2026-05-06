import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_counter_section.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_timed_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SheetTrackingConfigSection extends StatelessWidget {
  const SheetTrackingConfigSection({super.key});

  @override
  Widget build(BuildContext context) {
    final trackingType = context.select<NewHabitProvider, HabitTrackingType>(
      (p) => p.trackingType,
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      layoutBuilder: (currentChild, previousChildren) {
        return Stack(
          alignment: Alignment.topLeft,
          children: [
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },
      child: _buildSection(trackingType),
    );
  }

  Widget _buildSection(HabitTrackingType type) {
    return switch (type) {
      HabitTrackingType.counter => const SheetCounterSection(
        key: ValueKey('counter'),
      ),
      HabitTrackingType.timed => const SheetTimedSection(key: ValueKey('timed')),
      HabitTrackingType.single => const SizedBox.shrink(
        key: ValueKey('single'),
      ),
    };
  }
}

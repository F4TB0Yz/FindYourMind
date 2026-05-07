import 'package:find_your_mind/config/theme/app_colors.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/counter_habit_item_card/counter_habit_item_card.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/habit_card_wrapper/habit_card_animated_container.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/one_time_habit_item_card/one_time_habit_item_card.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/timed_habit_item_card/timed_habit_item_card.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HabitCardWrapper extends StatelessWidget {
  const HabitCardWrapper({required this.habit, super.key});

  final HabitEntity habit;

  @override
  Widget build(BuildContext context) {
    final isExpanded = context.select<HabitsProvider, bool>(
      (p) => p.expandedHabitId == habit.id,
    );
    final isCompleting = context.select<HabitsProvider, bool>(
      (p) => p.isCompletingAnimation(habit.id),
    );
    final isUncompleting = context.select<HabitsProvider, bool>(
      (p) => p.isUncompletingAnimation(habit.id),
    );
    final activeFilter = context.select<HabitsProvider, HabitFilter>(
      (p) => p.activeFilter,
    );
    final isVisible = context.select<HabitsProvider, bool>(
      (p) => p.isHabitVisible(habit.id),
    );
    final provider = context.read<HabitsProvider>();

    final color = habit.color == 'random'
        ? AppColors.habitCardColor(habit.id)
        : AppColors.habitCardColorFromHex(habit.color);

    final card = switch (habit.trackingType) {
      HabitTrackingType.single => OneTimeHabitItemCard(
        habit: habit,
        icon: habit.icon,
        title: habit.title,
        description: habit.description,
        cardColor: color,
        isExpanded: isExpanded,
        onExpandTap: () => provider.toggleExpanded(habit.id),
        onMarkCompletedTap: () => provider.handleOneTimeToggle(
          habit.id,
          habit.isCompletedToday,
        ),
      ),
      HabitTrackingType.timed => TimedHabitItemCard(
        habit: habit,
        icon: habit.icon,
        title: habit.title,
        description: habit.description,
        targetSeconds: habit.targetValue,
        elapsedSeconds: habit.todayValue,
        cardColor: color,
        isExpanded: isExpanded,
        onExpandTap: () => provider.toggleExpanded(habit.id),
        onTimerTick: (seconds) => provider.handleTimerTick(
          habit.id,
          seconds,
          habit.targetValue,
        ),
      ),
      HabitTrackingType.counter => CounterHabitItemCard(
        habit: habit,
        icon: habit.icon,
        title: habit.title,
        description: habit.description,
        currentCount: habit.todayValue,
        goalCount: habit.targetValue,
        cardColor: color,
        isExpanded: isExpanded,
        onExpandTap: () => provider.toggleExpanded(habit.id),
        onIncrement: habit.isCompletedToday
            ? null
            : () => provider.handleCounterIncrement(habit.id),
        onDecrement: habit.todayValue > 0
            ? () => provider.handleCounterDecrement(habit.id)
            : null,
      ),
    };

    return HabitCardAnimatedContainer(
      habitId: habit.id,
      isVisible: isVisible,
      shouldFade: isCompleting && activeFilter == HabitFilter.incompletos,
      shouldSlideBack: isUncompleting && activeFilter == HabitFilter.completados,
      isTimed: habit.trackingType == HabitTrackingType.timed,
      onLongPress: () => context.push('/habits/${habit.id}', extra: habit),
      child: card,
    );
  }
}

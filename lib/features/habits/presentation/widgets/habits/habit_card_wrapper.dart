import 'package:find_your_mind/config/theme/app_colors.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/counter_habit_item_card/counter_habit_item_card.dart';
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

    final shouldFade = isCompleting && activeFilter == HabitFilter.incompletos;
    final shouldSlideBack = isUncompleting && activeFilter == HabitFilter.completados;

    final color = AppColors.habitCardColor(habit.id);
    final card = switch (habit.trackingType) {
      HabitTrackingType.single => OneTimeHabitItemCard(
        habit: habit,
        icon: habit.icon,
        title: habit.title,
        description: habit.description,
        cardColor: color,
        isExpanded: isExpanded,
        onExpandTap: () => provider.toggleExpanded(habit.id),
        onMarkCompletedTap: habit.isCompletedToday
            ? () {
                provider.triggerUncompletionAnimation(habit.id);
                provider.setHabitLogValue(habit.id, 0);
              }
            : () {
                provider.triggerCompletionAnimation(habit.id);
                provider.updateHabitCounter(habit.id);
              },
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
        onTimerTick: (seconds) {
          provider.setHabitLogValue(habit.id, seconds);
          if (seconds >= habit.targetValue) {
            provider.triggerCompletionAnimation(habit.id);
          }
        },
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
            : () {
                if (habit.todayValue + 1 >= habit.targetValue) {
                  provider.triggerCompletionAnimation(habit.id);
                }
                provider.updateHabitCounter(habit.id);
              },
        onDecrement: habit.todayValue > 0
            ? () {
                if (habit.isCompletedToday) {
                  provider.triggerUncompletionAnimation(habit.id);
                }
                provider.decrementHabitProgress(habit.id);
              }
            : null,
      ),
    };

    final animated = AnimatedOpacity(
      key: ValueKey(habit.id),
      opacity: shouldFade || shouldSlideBack ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeIn,
      child: AnimatedSlide(
        offset: shouldFade
            ? const Offset(0.0, -0.12)
            : shouldSlideBack
                ? const Offset(0.12, 0.0)
                : Offset.zero,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        child: GestureDetector(
          onLongPress: () => context.push('/habits/${habit.id}', extra: habit),
          child: card,
        ),
      ),
    );

    if (habit.trackingType == HabitTrackingType.timed) {
      return Offstage(
        key: ValueKey('os_${habit.id}'),
        offstage: !isVisible,
        child: animated,
      );
    }

    if (!isVisible) return const SizedBox.shrink();
    return animated;
  }
}
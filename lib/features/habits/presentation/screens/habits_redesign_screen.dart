import 'package:find_your_mind/config/theme/app_colors.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/counter_habit_item_card/counter_habit_item_card.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/one_time_habit_item_card/one_time_habit_item_card.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/timed_habit_item_card/timed_habit_item_card.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/today_progress_card.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/weekly_habits_statistics.dart';
import 'package:find_your_mind/shared/presentation/widgets/layouts/feature_layout.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

enum _HabitFilter { todos, completados, incompletos }

class HabitsRedesignScreen extends StatelessWidget {
  const HabitsRedesignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeatureLayout(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TodayProgressCard(),
                WeeklyHabitsStatistics(),
                SizedBox(height: 8),
                _HabitsSection(),
                SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitsSection extends StatefulWidget {
  const _HabitsSection();

  @override
  State<_HabitsSection> createState() => _HabitsSectionState();
}

class _HabitsSectionState extends State<_HabitsSection> {
  String? _expandedHabitId;
  _HabitFilter _activeFilter = _HabitFilter.incompletos;

  static const _cardColors = [
    Color(0xFFDFFECF),
    Color(0xFFD6F5FF),
    Color(0xFFE8D8FF),
    Color(0xFFFFE4CC),
    Color(0xFFFFD9E6),
  ];

  void _handleExpandTap(String habitId) {
    setState(() {
      _expandedHabitId = _expandedHabitId == habitId ? null : habitId;
    });
  }

  Color _colorFor(String habitId) {
    final index = habitId.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return _cardColors[index % _cardColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<HabitsProvider>();

    final habits = provider.habits.where((habit) {
      if (_activeFilter == _HabitFilter.completados) {
        return habit.isCompletedToday;
      }
      if (_activeFilter == _HabitFilter.incompletos) {
        return !habit.isCompletedToday;
      }
      return true;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tus hábitos',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  _AnimatedFilterChip(
                    label: 'Todos',
                    isActive: _activeFilter == _HabitFilter.todos,
                    onTap: () =>
                        setState(() => _activeFilter = _HabitFilter.todos),
                  ),
                  const SizedBox(width: 4),
                  _AnimatedFilterChip(
                    label: 'Completos',
                    isActive: _activeFilter == _HabitFilter.completados,
                    onTap: () => setState(
                      () => _activeFilter = _HabitFilter.completados,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _AnimatedFilterChip(
                    label: 'Incompletos',
                    isActive: _activeFilter == _HabitFilter.incompletos,
                    onTap: () => setState(
                      () => _activeFilter = _HabitFilter.incompletos,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/habits/new'),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? const Color(0xFFecfeff).withValues(alpha: 0.12)
                        : const Color(0xFF15B0B8).withValues(alpha: 0.28),
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedAdd01,
                      size: 20,
                      color: isDark
                          ? const Color(0xFF67e8f9)
                          : const Color(0xFF155e75),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (habits.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Text(
              'No hay hábitos para este filtro.',
              style: textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ...habits.map((habit) => _buildHabitCard(context, provider, habit)),
      ],
    );
  }

  Widget _buildHabitCard(
    BuildContext context,
    HabitsProvider provider,
    HabitEntity habit,
  ) {
    final color = _colorFor(habit.id);
    final isExpanded = _expandedHabitId == habit.id;

    final card = switch (habit.trackingType) {
      HabitTrackingType.single => OneTimeHabitItemCard(
        key: ValueKey(habit.id),
        icon: habit.icon,
        title: habit.title,
        description: habit.description,
        streakDays: habit.streak,
        isCompleted: habit.isCompletedToday,
        cardColor: color,
        isExpanded: isExpanded,
        onExpandTap: () => _handleExpandTap(habit.id),
        onMarkCompletedTap: habit.isCompletedToday
            ? () => provider.setHabitLogValue(habit.id, 0)
            : () => provider.updateHabitCounter(habit.id),
      ),
      HabitTrackingType.timed => TimedHabitItemCard(
        key: ValueKey(habit.id),
        icon: habit.icon,
        title: habit.title,
        description: habit.description,
        streakDays: habit.streak,
        targetSeconds: habit.targetValue,
        elapsedSeconds: habit.todayValue,
        cardColor: color,
        isExpanded: isExpanded,
        onExpandTap: () => _handleExpandTap(habit.id),
        onTimerTick: (seconds) => provider.setHabitLogValue(habit.id, seconds),
      ),
      HabitTrackingType.counter => CounterHabitItemCard(
        key: ValueKey(habit.id),
        icon: habit.icon,
        title: habit.title,
        description: habit.description,
        streakDays: habit.streak,
        currentCount: habit.todayValue,
        goalCount: habit.targetValue,
        cardColor: color,
        isExpanded: isExpanded,
        onExpandTap: () => _handleExpandTap(habit.id),
        onIncrement: habit.isCompletedToday
            ? null
            : () => provider.updateHabitCounter(habit.id),
        onDecrement: habit.todayValue > 0
            ? () => provider.decrementHabitProgress(habit.id)
            : null,
      ),
    };

    return GestureDetector(
      onLongPress: () => context.push('/habits/${habit.id}', extra: habit),
      child: card,
    );
  }
}

class _AnimatedFilterChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _AnimatedFilterChip({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: isDark ? 0.18 : 0.14)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isActive)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark
                      ? AppColors.darkOnSurfaceVariant.withValues(alpha: 0.4)
                      : AppColors.lightOnSurfaceVariant.withValues(alpha: 0.4),
                ),
              ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: ClipRect(
                child: SizedBox(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 220),
                    opacity: isActive ? 1.0 : 0.0,
                    child: isActive
                        ? Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: activeColor,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

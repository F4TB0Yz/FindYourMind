import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/statistics_habit.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/weekly_progress/weekly_progress.dart';
import 'package:flutter/material.dart';

class DetailsView extends StatelessWidget {
  final HabitEntity habit;
  static const String _defaultEmoji = '🧠';

  const DetailsView({super.key, required this.habit});

  String _trackingLabel() {
    switch (habit.trackingType.name) {
      case 'single':
        return 'Una vez';
      case 'timed':
        return 'Tiempo';
      default:
        return 'Conteo';
    }
  }

  String _targetLabel() {
    switch (habit.trackingType.name) {
      case 'single':
        return '1 vez';
      case 'timed':
        return '${habit.targetValue ~/ 60} min meta';
      default:
        return '${habit.targetValue} repeticiones';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cs.surface,
              shape: BoxShape.circle,
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Text(
              habit.icon.isNotEmpty ? habit.icon : _defaultEmoji,
              style: const TextStyle(fontSize: 44),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _MetaChip(label: _trackingLabel()),
            _MetaChip(label: habit.category.name),
            _MetaChip(label: _targetLabel()),
          ],
        ),
        const SizedBox(height: 36),
        Text(
          'Progreso semanal',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        WeeklyProgress(habit: habit),
        const SizedBox(height: 36),
        Text(
          'Estadísticas',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        StatisticsHabit(habit: habit),
        const SizedBox(height: 48),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;

  const _MetaChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

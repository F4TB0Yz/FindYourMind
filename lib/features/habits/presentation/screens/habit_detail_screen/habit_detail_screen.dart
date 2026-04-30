import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habit_detail_screen/details_view.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habit_detail_screen/editing_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:hugeicons/hugeicons.dart';

class HabitDetailScreen extends StatefulWidget {
  final HabitEntity habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late bool _isEditing;
  late HabitsProvider _habitsProvider;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    _habitsProvider = Provider.of<HabitsProvider>(context);
    _isEditing = _habitsProvider.isEditing;

    // Obtener el hábito actualizado desde el provider para reflejar cambios en tiempo real
    final currentHabit = _habitsProvider.habits.firstWhere(
      (h) => h.id == widget.habit.id,
      orElse: () => widget.habit,
    );

    return Column(
      children: [
        _HabitDetailHeader(
          habit: currentHabit,
          isEditing: _isEditing,
          onToggleEdit: () => _habitsProvider.changeIsEditing(!_isEditing),
        ),
        Divider(height: 1, thickness: 1, color: cs.outlineVariant),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: !_isEditing
                ? DetailsView(habit: currentHabit)
                : EditingView(habit: currentHabit),
          ),
        ),
      ],
    );
  }
}

/// Nuevo header nativo para la vista de detalle.
class _HabitDetailHeader extends StatelessWidget {
  final HabitEntity habit;
  final bool isEditing;
  final VoidCallback onToggleEdit;

  const _HabitDetailHeader({
    required this.habit,
    required this.isEditing,
    required this.onToggleEdit,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
            onPressed: () {
              // Si está editando y presiona atrás, salir de edición. Si no, volver a la lista.
              if (isEditing) {
                onToggleEdit();
              } else {
                context.pop();
              }
            },
            padding: const EdgeInsets.all(8),
            splashRadius: 24,
            tooltip: 'Volver',
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEditing)
                  Text(
                    '${habit.daysSinceStart + 1} días activos',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          _EditToggleButton(isEditing: isEditing, onToggle: onToggleEdit),
        ],
      ),
    );
  }
}

/// Botón discreto para editar/cancelar.
class _EditToggleButton extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onToggle;

  const _EditToggleButton({required this.isEditing, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isEditing
              ? cs.error.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isEditing
                ? cs.error.withValues(alpha: 0.4)
                : cs.outlineVariant,
            width: 1,
          ),
        ),
        child: Text(
          isEditing ? 'Cancelar' : 'Editar',
          style: TextStyle(
            color: isEditing ? cs.error : cs.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

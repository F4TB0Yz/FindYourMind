import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/add_icon.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/daily_goal_counter.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class EditingView extends StatefulWidget {
  final HabitEntity habit;

  const EditingView({super.key, required this.habit});

  @override
  State<EditingView> createState() => _EditingViewState();
}

class _EditingViewState extends State<EditingView> {
  late int _targetValue;
  late String _selectedIcon;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _targetValue = widget.habit.targetValue;
    _selectedIcon = widget.habit.icon;
    _titleController = TextEditingController(text: widget.habit.title);
    _descriptionController = TextEditingController(text: widget.habit.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Icono',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outlineVariant),
                  color: cs.surface,
                ),
                padding: const EdgeInsets.all(4),
                child: AddIcon(
                  size: 64,
                  saveIcon: (newIcon) {
                    setState(() {
                      _selectedIcon = newIcon;
                    });
                  },
                  withText: false,
                  initialIcon: _selectedIcon,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: cs.surfaceContainerLowest, width: 2),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedPencilEdit01,
                    color: cs.onPrimary,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _LabeledTextField(
          controller: _titleController,
          label: 'Título',
          hint: 'Ej. Leer un libro',
        ),
        const SizedBox(height: 20),
        _LabeledTextField(
          controller: _descriptionController,
          label: 'Descripción',
          hint: 'Notas adicionales sobre el hábito',
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        Text(
          'Meta',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        DailyGoalCounter(
          useProvider: false,
          initialValue: _targetValue,
          trackingType: widget.habit.trackingType,
          onChanged: widget.habit.trackingType == HabitTrackingType.single
              ? null
              : (newValue) {
                  setState(() {
                    _targetValue = newValue;
                  });
                },
        ),
        const SizedBox(height: 48),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _saveHabit(habitsProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.tertiary.withValues(alpha: 0.15),
              foregroundColor: cs.tertiary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: cs.tertiary.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              'Guardar cambios',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _saveHabit(HabitsProvider habitsProvider) async {
    if (_titleController.text.trim().isEmpty) {
      CustomToast.showToast(context: context, message: 'El título es requerido');
      return;
    }

    final todayCount = habitsProvider.getTodayCount(widget.habit.id);
    if (_targetValue < todayCount) {
      CustomToast.showToast(
        context: context,
        message: 'La meta no puede ser menor que tu valor de hoy ($todayCount)',
      );
      return;
    }

    final updatedHabit = widget.habit.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      icon: _selectedIcon,
      targetValue: _targetValue,
    );

    final success = await habitsProvider.updateHabit(updatedHabit);
    if (!success || !mounted) return;

    habitsProvider.changeIsEditing(false);
    CustomToast.showToast(context: context, message: 'Hábito guardado');
    context.pop();
  }
}

class _LabeledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;

  const _LabeledTextField({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurface,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.outline,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

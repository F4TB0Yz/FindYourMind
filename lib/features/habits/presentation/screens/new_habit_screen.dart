import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/add_icon.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/daily_goal_counter.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habit_tracking_type_selector.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/type_habit_selector.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class NewHabitScreen extends StatefulWidget {
  const NewHabitScreen({super.key});

  @override
  State<NewHabitScreen> createState() => _NewHabitScreenState();
}

class _NewHabitScreenState extends State<NewHabitScreen> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final habitsProvider = Provider.of<HabitsProvider>(context);
    final newHabitProvider = Provider.of<NewHabitProvider>(context);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            _NewHabitHeader(onBack: () => context.pop()),
            Divider(height: 1, thickness: 1, color: cs.outlineVariant),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
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
                              saveIcon: newHabitProvider.setSelectedIcon,
                              withText: false,
                              initialIcon: newHabitProvider.selectedIcon,
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
                                border: Border.all(
                                  color: cs.surfaceContainerLowest,
                                  width: 2,
                                ),
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
                      controller: newHabitProvider.titleController,
                      label: 'Título',
                      hint: 'Ej. Leer un libro',
                    ),
                    const SizedBox(height: 20),
                    _LabeledTextField(
                      controller: newHabitProvider.descriptionController,
                      label: 'Descripción',
                      hint: 'Notas adicionales sobre el hábito',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    const TypeHabitSelector(),
                    const SizedBox(height: 24),
                    const HabitTrackingTypeSelector(),
                    const SizedBox(height: 24),
                    Text(
                      'Meta',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const DailyGoalCounter(),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _onTapSaveHabit(
                          context,
                          newHabitProvider,
                          habitsProvider,
                        ),
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
                          'Crear Hábito',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.tertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapSaveHabit(
    BuildContext context,
    NewHabitProvider newHabitProvider,
    HabitsProvider habitsProvider,
  ) async {
    final userId = await habitsProvider.getUserId();

    if (userId == null) {
      if (context.mounted) {
        CustomToast.showToast(
          context: context,
          message: 'Error: No se pudo identificar al usuario',
        );
      }
      return;
    }

    final habit = HabitEntity(
      id: '',
      userId: userId,
      title: newHabitProvider.titleController.text,
      description: newHabitProvider.descriptionController.text,
      icon: newHabitProvider.selectedIcon,
      color: newHabitProvider.selectedColor,
      unit: newHabitProvider.unitController.text.isNotEmpty
          ? newHabitProvider.unitController.text
          : null,
      category: newHabitProvider.selectedCategory,
      trackingType: newHabitProvider.trackingType,
      targetValue: newHabitProvider.targetValue,
      initialDate: DateTime.now().toIso8601String(),
      logs: const [],
    );

    if (!_verifyFields(habit)) return;
    if (!context.mounted) return;

    context.pop();
    CustomToast.showToast(context: context, message: 'Hábito creado');
    newHabitProvider.clear();
    habitsProvider.createHabit(habit);
  }

  bool _verifyFields(HabitEntity habit) {
    if (habit.title.trim().isEmpty) {
      CustomToast.showToast(
        context: context,
        message: 'El título es requerido',
      );
      return false;
    }

    if (habit.category == HabitCategory.none) {
      CustomToast.showToast(
        context: context,
        message: 'Selecciona una categoría',
      );
      return false;
    }

    return true;
  }
}

class _NewHabitHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _NewHabitHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
      child: Row(
        children: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedCancel01,
              size: 24,
              color: cs.onSurfaceVariant,
            ),
            onPressed: onBack,
            padding: const EdgeInsets.all(8),
            splashRadius: 24,
            tooltip: 'Cancelar',
          ),
        ],
      ),
    );
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
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

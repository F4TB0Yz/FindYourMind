import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/type_habit.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/add_icon.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/daily_goal_counter.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/type_habit_selector.dart';
import 'package:find_your_mind/shared/presentation/widgets/container_border_screens.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
    final HabitsProvider habitsProvider = Provider.of<HabitsProvider>(context);
    final NewHabitProvider newHabitProvider = Provider.of<NewHabitProvider>(context);

    return ContainerBorderScreens(
      child: Column(
        children: [
          _NewHabitHeader(
            onBack: () => context.pop(),
          ),
          Divider(height: 1, thickness: 1, color: cs.outlineVariant),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    
                    // Icono
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
                              saveIcon: (newIcon) => newHabitProvider.setSelectedIcon(newIcon), 
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
                                border: Border.all(color: cs.surfaceContainerLowest, width: 2),
                              ),
                              child: Icon(
                                Icons.edit,
                                color: cs.onPrimary,
                                size: 14,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Título del hábito
                    _LabeledTextField(
                      controller: newHabitProvider.titleController,
                      label: 'Título',
                      hint: 'Ej. Leer un libro',
                    ),

                    const SizedBox(height: 20),

                    // Descripción
                    _LabeledTextField(
                      controller: newHabitProvider.descriptionController,
                      label: 'Descripción (Opcional)',
                      hint: 'Notas adicionales sobre el hábito',
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),
                    
                    // Tipo
                    Text(
                      'Tipo',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    const TypeHabitSelector(),

                    const SizedBox(height: 24),

                    // Meta Diaria
                    Text(
                      'Meta Diaria',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    const DailyGoalCounter(),

                    const SizedBox(height: 48),

                    // Botón Guardar
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _onTapSaveHabit(context, newHabitProvider, habitsProvider),
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
        )
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
      type: newHabitProvider.typeHabitSelected,
      dailyGoal: newHabitProvider.dailyGoal,
      initialDate: DateTime.now().toIso8601String(),
      progress: const [],
    );

    if (!_verifyFields(habit)) return;

    if (!context.mounted) return;

    context.pop();
    CustomToast.showToast(context: context, message: 'Hábito Creado');

    newHabitProvider.clear();
    
    // 🚀 Fire-and-Forget: createHabit es síncrono para la UI (optimistic insert).
    habitsProvider.createHabit(habit);
  }

  bool _verifyFields(HabitEntity habit) {
    if (habit.title.isEmpty) {
      CustomToast.showToast(
        context: context,
        message: 'El título es requerido',
      );
      return false;
    }

    if (habit.type == TypeHabit.none) {
      CustomToast.showToast(
        context: context,
        message: 'Selecciona un tipo de hábito',
      );
      return false;
    }

    return true;
  }
}

/// Header nativo superior.
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
            icon: Icon(Icons.close, size: 24, color: cs.onSurfaceVariant),
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

/// Campo de texto de estilo linear, enclosed en un container de fondo.
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

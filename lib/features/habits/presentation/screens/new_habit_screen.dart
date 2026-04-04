import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/type_habit.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habits_screen.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/add_icon.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/daily_goal_counter.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/type_habit_selector.dart';
import 'package:find_your_mind/shared/domain/entities/screen_type.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewHabitScreen extends StatefulWidget {
  const NewHabitScreen({super.key});

  @override
  State<NewHabitScreen> createState() => _NewHabitScreenState();
}

class _NewHabitScreenState extends State<NewHabitScreen> {
  @override
  Widget build(BuildContext context) {
    final HabitsProvider habitsProvider = Provider.of<HabitsProvider>(context);
    final NewHabitProvider newHabitProvider = Provider.of<NewHabitProvider>(context);
    final ScreensProvider screensProvider = Provider.of<ScreensProvider>(context, listen: false);

    return Column(
      children: [
        _NewHabitHeader(
          onBack: () => screensProvider.setScreenWidget(const HabitsScreen(), ScreenType.habits),
        ),
        const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
        
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    
                    // Icono
                    const Text(
                      'Icono',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderSubtle),
                              color: AppColors.darkBackground,
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
                                color: AppColors.accentText,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.darkBackgroundAlt, width: 2),
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: AppColors.darkBackgroundAlt,
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
                    const Text(
                      'Tipo',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    const TypeHabitSelector(),

                    const SizedBox(height: 24),

                    // Meta Diaria
                    const Text(
                      'Meta Diaria',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
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
                        onPressed: () => _onTapSaveHabit(context, newHabitProvider, habitsProvider, screensProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.successMuted.withValues(alpha: 0.15),
                          foregroundColor: AppColors.successMuted,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: AppColors.successMuted.withValues(alpha: 0.4),
                              width: 1,
                            )
                          ),
                        ),
                        child: const Text(
                          'Crear Hábito',
                          style: TextStyle(
                            fontSize: 15,
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
        );
  }

  void _onTapSaveHabit(
    BuildContext context,
    NewHabitProvider newHabitProvider,
    HabitsProvider habitsProvider,
    ScreensProvider screensProvider,
  ) async {
    final userId = await habitsProvider.getUserId();
    
    final habit = HabitEntity(
      id: '',
      userId: userId,
      title: newHabitProvider.titleController.text,
      description: newHabitProvider.descriptionController.text,
      icon: newHabitProvider.selectedIcon,
      type: newHabitProvider.typeHabitSelected,
      dailyGoal: newHabitProvider.dailyGoal,
      initialDate: DateTime.now().toIso8601String(),
      progress: [],
    );

    if (!_verifyFields(habit)) return;

    if (!context.mounted) return;

    screensProvider.setScreenWidget(const HabitsScreen(), ScreenType.habits);
    CustomToast.showToast(context: context, message: 'Hábito Creado');

    newHabitProvider.clear();
    
    // 🚀 Fire-and-Forget: createHabit es síncrono para la UI (optimistic insert).
    // La persistencia ocurre en background. No bloqueamos aquí.
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 24, color: AppColors.textSecondary),
            onPressed: onBack,
            padding: const EdgeInsets.all(8),
            splashRadius: 24,
            tooltip: 'Cancelar',
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Nuevo Hábito',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: AppColors.textMuted),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}

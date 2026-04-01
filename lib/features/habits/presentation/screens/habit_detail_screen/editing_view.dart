import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habits_screen.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/add_icon.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/daily_goal_counter.dart';
import 'package:find_your_mind/shared/domain/entities/screen_type.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditingView extends StatefulWidget {
  final HabitEntity habit;

  const EditingView({super.key, required this.habit});

  @override
  State<EditingView> createState() => _EditingViewState();
}

class _EditingViewState extends State<EditingView> {
  late int _dailyGoal;
  late String _selectedIcon;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _dailyGoal = widget.habit.dailyGoal;
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
    final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);
    final screensProvider = Provider.of<ScreensProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),

        // Selector de icono
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
          controller: _titleController,
          label: 'Título',
          hint: 'Ej. Leer un libro',
        ),

        const SizedBox(height: 20),

        // Descripción
        _LabeledTextField(
          controller: _descriptionController,
          label: 'Descripción (Opcional)',
          hint: 'Notas adicionales sobre el hábito',
          maxLines: 3,
        ),

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

        // El contador opera en modo local: muestra la meta actual del hábito
        // y notifica cambios al estado local mediante onChanged.
        DailyGoalCounter(
          useProvider: false,
          initialValue: _dailyGoal,
          onChanged: (newGoal) {
            setState(() {
              _dailyGoal = newGoal;
            });
          },
        ),

        const SizedBox(height: 48),

        // Botón único principal
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => _saveHabit(habitsProvider, screensProvider),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.successMuted.withValues(alpha: 0.15),
              foregroundColor: AppColors.successMuted,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: AppColors.successMuted.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            ),
            child: const Text(
              'Guardar Cambios',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _saveHabit(HabitsProvider habitsProvider, ScreensProvider screensProvider) async {
    if (_titleController.text.trim().isEmpty) {
      CustomToast.showToast(
        context: context,
        message: 'El título es requerido',
      );
      return;
    }

    // Validar que la nueva meta diaria no sea menor que el progreso de hoy.
    // Si el usuario ya registró 5 de 5 y baja la meta a 3, no debe poderse guardar.
    final int todayCount = habitsProvider.getTodayCount(widget.habit.id);
    if (_dailyGoal < todayCount) {
      CustomToast.showToast(
        context: context,
        message: 'La meta diaria no puede ser menor que tu progreso de hoy ($todayCount)',
      );
      return;
    }

    try {
      final updatedHabit = widget.habit.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        icon: _selectedIcon,
        dailyGoal: _dailyGoal,
      );

      habitsProvider.updateHabit(updatedHabit);
      habitsProvider.changeIsEditing(false);

      if (!mounted) return;

      CustomToast.showToast(
        context: context,
        message: 'Hábito guardado',
      );

      screensProvider.setScreenWidget(const HabitsScreen(), ScreenType.habits);
    } catch (e) {
      if (!mounted) return;
      CustomToast.showToast(
        context: context,
        message: 'Error al actualizar',
      );
    }
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
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habits_screen.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/add_icon.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/custom_button.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/daily_goal_counter.dart';
import 'package:find_your_mind/shared/domain/screen_type.dart';
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
        const SizedBox(height: 15),

        // Selector de icono
        const Text(
          'Icono del Hábito',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white38,
          ),
        ),
        const SizedBox(height: 10),

        Stack(
          children: [
            AddIcon(
              size: 64,
              saveIcon: (newIcon) {
                setState(() {
                  _selectedIcon = newIcon;
                });
              }, 
              withText: false,
              initialIcon: _selectedIcon,
            ),

            const SizedBox(width: 10),

            const Positioned(
              left: 60,
              top: 0,
              child: Icon(
                Icons.mode_edit_outline_outlined,
                color: Color.fromARGB(255, 187, 180, 155),
                size: 24,
              ),
            )
          ],
        ),

        const SizedBox(height: 20),

        // Título del hábito
        _buildCustomTextField(
          controller: _titleController,
          label: 'Título del Hábito',
          fontSize: 18,
        ),

        const SizedBox(height: 15),

        // Descripción
        _buildCustomTextField(
          controller: _descriptionController,
          label: 'Descripción',
          fontSize: 14,
          isSubtitle: true,
        ),

        const SizedBox(height: 20),

        // Meta Diaria
        const Text(
          'Meta Diaria',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white38,
          ),
        ),

        const SizedBox(height: 10),

        DailyGoalCounter(
          useProvider: false,
          initialValue: _dailyGoal,
          onChanged: (newValue) {
            setState(() {
              _dailyGoal = newValue;
            });
          },
        ),

        const SizedBox(height: 50),

        // Botones de acción
        Row(
          children: [
            Expanded(
              child: CustomButton(
                title: 'CANCELAR',
                onTap: () {
                  setState(() {
                    // Restaurar valores originales
                    habitsProvider.changeIsEditing(false);
                    _titleController.text = widget.habit.title;
                    _descriptionController.text = widget.habit.description;
                    _selectedIcon = widget.habit.icon;
                    _dailyGoal = widget.habit.dailyGoal;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: CustomButton(
                title: 'GUARDAR',
                onTap: () => _saveHabit(habitsProvider, screensProvider),
              ),
            ),
          ],
        ),

        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required double fontSize,
    bool isSubtitle = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isSubtitle ? Colors.white24 : Colors.white38,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          maxLength: isSubtitle ? null : 30,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  Future<void> _saveHabit(HabitsProvider habitsProvider, ScreensProvider screensProvider) async {
    if (_titleController.text.trim().isEmpty) {
      CustomToast.showToast(
        context: context,
        message: 'El título no puede estar vacío',
      );
      return;
    }

    try {
      // Crear el hábito actualizado con los nuevos valores
      final updatedHabit = widget.habit.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        icon: _selectedIcon,
        dailyGoal: _dailyGoal,
      );

      // 🚀 Actualización optimista: no esperar, la UI se actualiza inmediatamente
      habitsProvider.updateHabit(updatedHabit);

      // Salir del modo edición inmediatamente
      habitsProvider.changeIsEditing(false);

      if (!mounted) return;

      CustomToast.showToast(
        context: context,
        message: 'Hábito actualizado exitosamente',
      );

      // Navegar de vuelta inmediatamente
      screensProvider.setScreenWidget(const HabitsScreen(), ScreenType.habits);

    } catch (e) {
      if (!mounted) return;

      CustomToast.showToast(
        context: context,
        message: 'Error al actualizar el hábito',
      );
    }
  }
}
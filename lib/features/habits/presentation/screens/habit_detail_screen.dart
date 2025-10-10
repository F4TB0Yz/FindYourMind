import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habits_screen.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/add_icon.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/container_border_habits.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/custom_button.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/daily_goal_counter.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/statistics_habit.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/weekly_progress/weekly_progress.dart';
import 'package:find_your_mind/shared/domain/screen_type.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class HabitDetailScreen extends StatefulWidget {
  final HabitEntity habit;

  const HabitDetailScreen({
    super.key,
    required this.habit,
  });

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  bool isEditing = false;
  
  late ScreensProvider screensProvider;
  late HabitsProvider habitsProvider;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late String _selectedIcon;
  late int _dailyGoal;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.title);
    _descriptionController = TextEditingController(text: widget.habit.description);
    _selectedIcon = widget.habit.icon;
    _dailyGoal = widget.habit.dailyGoal;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    habitsProvider = Provider.of<HabitsProvider>(context);
    screensProvider = Provider.of<ScreensProvider>(context);

    // Obtener el hábito actualizado del provider
    final currentHabit = habitsProvider.habits.firstWhere(
      (h) => h.id == widget.habit.id,
      orElse: () => widget.habit,
    );

    return ContainerBorderHabits(
      crossAxisAlignment: CrossAxisAlignment.start,
      endWidget: _buildToggleEditButton(),
      child: Column(
        children: [
          // Container First Info
          _buildHabitInfoContainer(currentHabit),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4.0),
              child: !isEditing 
                ? _buildViewMode(currentHabit)
                : _buildEditingMode()
            )
          ),
        ],
      ),
    );
  }

  Widget _buildViewMode(HabitEntity currentHabit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // Icono actual
        Center(
          child: SvgPicture.asset(
            currentHabit.icon,
            width: 100,
            height: 100,
          ),
        ),
        const SizedBox(height: 10),

        const Center(
          child: Text(
            'Tú Semana',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white60,
            ),
          ),
        ),

        const SizedBox(height: 10),

        WeeklyProgress(habit: currentHabit),

        const SizedBox(height: 25),

        // Estadísticas
        StatisticsHabit(habit: currentHabit),

        const Spacer(),

        // Botones
        Row(
        children: [
          Expanded(
          child: CustomButton(
            title: 'CANCELAR',
            onTap: () {
              screensProvider.setScreenWidget(const HabitsScreen(), ScreenType.habits);
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

  Widget _buildEditingMode() {
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

            Positioned(
              left: 60,
              top: 0,
              child: Icon(
                Icons.mode_edit_outline_outlined,
                color: Colors.amber.shade300,
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
            fontSize: 12,
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

        const Spacer(),

        // Botones de acción
        Row(
          children: [
            Expanded(
              child: CustomButton(
                title: 'CANCELAR',
                onTap: () {
                  setState(() {
                    isEditing = false;
                    // Restaurar valores originales
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
  
  Widget _buildHabitInfoContainer(HabitEntity currentHabit) {
    final totalDays = currentHabit.daysSinceStart + 1;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      color: AppColors.darkBackground,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Días desde el inicio
          Text(
            totalDays.toString(),
            style: const TextStyle(
              fontSize: 64,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              height: 1.0, // Reduce el espacio vertical entre líneas
            ),
          ),

          const SizedBox(height: 10),

          Text(
            totalDays == 1 ? 'Día' : 'Días',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white60,
              fontWeight: FontWeight.w500,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleEditButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isEditing = !isEditing;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isEditing 
              ? const Color.fromARGB(40, 163, 36, 36)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isEditing 
                ? const Color.fromARGB(255, 83, 8, 8)
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Icon(
          isEditing ? Icons.close : Icons.edit,
          color: Colors.white,
          size: 14,
        ),
      ),
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
            fontSize: 14,
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

      // Actualizar usando el provider que internamente usa el caso de uso
      // Esto actualiza tanto en la base de datos como en el estado local
      await habitsProvider.updateHabit(updatedHabit);

      if (!mounted) return;

      CustomToast.showToast(
        context: context,
        message: 'Hábito actualizado exitosamente',
      );

      setState(() {
        isEditing = false;
        screensProvider.setScreenWidget(const HabitsScreen(), ScreenType.habits);
      });

    } catch (e) {
      if (!mounted) return;

      CustomToast.showToast(
        context: context,
        message: 'Error al actualizar el hábito',
      );
    }
  }
}
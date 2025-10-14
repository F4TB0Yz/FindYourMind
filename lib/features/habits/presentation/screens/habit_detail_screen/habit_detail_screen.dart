import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habit_detail_screen/details_view.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habit_detail_screen/editing_view.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/container_border_habits.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:flutter/material.dart';
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
  late bool isEditing;
  late ScreensProvider screensProvider;
  late HabitsProvider habitsProvider;

  @override
  Widget build(BuildContext context) {
    habitsProvider = Provider.of<HabitsProvider>(context);
    screensProvider = Provider.of<ScreensProvider>(context);
    isEditing = habitsProvider.isEditing;

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4.0),
              child: !isEditing 
                ? DetailsView(habit: currentHabit)
                : EditingView(habit: currentHabit)
            )
          ),
        ],
      ),
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
        habitsProvider.changeIsEditing(!isEditing);
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

}
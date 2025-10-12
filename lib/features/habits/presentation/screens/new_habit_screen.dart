import 'package:find_your_mind/core/data/supabase_habits_service.dart';
import 'package:find_your_mind/core/utils/date_utils.dart' as custom_date_utils;
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/entities/type_habit.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habits_screen.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/add_icon.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/container_border_habits.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/custom_button.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/daily_goal_counter.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/type_habit_selector.dart';
import 'package:find_your_mind/shared/domain/screen_type.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class NewHabitScreen extends StatefulWidget {
  const NewHabitScreen({super.key});

  @override
  State<NewHabitScreen> createState() => _NewHabitScreenState();
}

class _NewHabitScreenState extends State<NewHabitScreen> {
  String selectedIcon = 'assets/icons/mind.svg';
  
  @override
  Widget build(BuildContext context) {
    final HabitsProvider habitsProvider = Provider.of<HabitsProvider>(context);
    final NewHabitProvider newHabitProvider = Provider.of<NewHabitProvider>(context); 
    final ScreensProvider screensProvider = Provider.of<ScreensProvider>(context);

    return ContainerBorderHabits(
      crossAxisAlignment: CrossAxisAlignment.start,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Agregar Icono
            AddIcon(
              size: 52,
              saveIcon: (String iconPath) => {
                newHabitProvider.setSelectedIcon(iconPath),
              },
            ),

            // Titulo Habito
            _buildTextField(
              textController: newHabitProvider.titleController,
              title: 'Titulo del Habito', 
              fontSize: 18
            ),

            // Descripcion Habito
            _buildTextField(
              textController: newHabitProvider.descriptionController,
              title: 'Descripcion del Habito', 
              fontSize: 16, 
              isSubtitle: true
            ),

            const SizedBox(height: 20),

            // Tipo de Habito
            const TypeHabitSelector(),

            const SizedBox(height: 20),

            // Meta
            const Text(
              'Meta Diaria',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white38
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              '¿Cuantas veces al dia quieres cumplir tu habito?, como beber agua (5) veces al dia',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white24
              ),
            ),

            const SizedBox(height: 20),

            const DailyGoalCounter(),

            const Spacer(),

            // Button Guardar
            CustomButton(
              title: 'Guardar Habito',
              onTap: () => _onTapSaveHabit(context, newHabitProvider, habitsProvider, screensProvider),
            ),

            const SizedBox(height: 5)
          ],
        ),
      )
    );
  }

  void _onTapSaveHabit(
    BuildContext context,
    NewHabitProvider newHabitProvider, 
    HabitsProvider habitsProvider,
    ScreensProvider screensProvider
  ) async {
    final habit = HabitEntity(
      id: '', // El id lo genera Supabase,
      userId: 'c2fa89e9-ab8e-4592-b14e-223d7d7aa55d', // TODO: CAMBIAR POR ID DEL USUARIO CUANDO HAYA AUTH,
      title: newHabitProvider.titleController.text,
      description: newHabitProvider.descriptionController.text,
      icon: newHabitProvider.selectedIcon,
      type: newHabitProvider.typeHabitSelected,
      dailyGoal: newHabitProvider.dailyGoal,
      initialDate: DateTime.now().toIso8601String(),
      progress: []
    );

    if (!_verifyFields(habit)) return;

    final supabaseService = SupabaseHabitsService();
    final String? habitId = await supabaseService.saveHabit(habit);

    if (habitId == null && context.mounted) {
      CustomToast.showToast(
        context: context, 
        message: 'Error al guardar el habito'
      );
      return;
    } 

    habitsProvider.addHabit(habit.copyWith(id: habitId));

    if (!context.mounted) return;
    screensProvider.setScreenWidget(const HabitsScreen(), ScreenType.habits);

    CustomToast.showToast(
      context: context, 
      message: 'Habito Guardado'
    );

    newHabitProvider.clear();

    final String todayString = custom_date_utils.DateUtils.todayString();

    final String? progressId = await supabaseService.createHabitProgress(
      habitId: habitId!, 
      date: todayString, 
      dailyCounter: 0, 
      dailyGoal: habit.dailyGoal
    );
    
    if (progressId == null) return;

    final HabitProgress todayProgress = HabitProgress(
      id: progressId, 
      habitId: habitId, 
      date: todayString, 
      dailyGoal: habit.dailyGoal, 
      dailyCounter: 0
    );

    habitsProvider.updateHabitProgress(todayProgress);
  }

  bool _verifyFields(HabitEntity habit) {
    if (habit.title.isEmpty) {
      CustomToast.showToast(
        context: context, 
        message: 'El titulo no puede estar vacio'
      );
      return false;
    }



    if (habit.type == TypeHabit.none) {
      CustomToast.showToast(
        context: context, 
        message: 'Selecciona un tipo de habito'
      );
      return false;
    }
    
    return true;
  }

  Widget _buildTextField({
    required TextEditingController textController, 
    String? title,
    double fontSize = 12, 
    bool isSubtitle = false
  }) {
    return TextField(
      controller: textController,
      maxLength: isSubtitle ? null : 20,
      decoration: InputDecoration(
        hintText: title,
        hintStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white60
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: isSubtitle ? Colors.white60 : Colors.white,
      ),
      cursorColor: Colors.white70,
    );
  }
}
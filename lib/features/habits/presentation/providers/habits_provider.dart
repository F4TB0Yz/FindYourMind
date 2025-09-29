import 'package:find_your_mind/core/data/supabase_habits_service.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:flutter/material.dart';

class HabitsProvider extends ChangeNotifier {
  final List<HabitEntity> _habits = [];

  List<HabitEntity> get habits => _habits;

  void addHabit(HabitEntity habit) {
    _habits.add(habit);
    notifyListeners();
  }

  Future<void> loadHabits() async {
    final SupabaseHabitsService supabaseService = SupabaseHabitsService();
    final List<HabitEntity> habits = await supabaseService.getHabitsByEmail('jfduarte09@gmail.com');

    print('Habits loaded: ${habits.length}');

    for (HabitEntity habit in habits) {
      print('Habit: ${habit.title}, Initial Date: ${habit.initialDate}');
    }

   _habits.addAll(habits);
   notifyListeners();
  }

  Future<void> updateHabitProgress(HabitProgress todayProgress) async {
    // Buscar el hábito por ID
    final habitIndex = _habits.indexWhere(
      (habit) => habit.id == todayProgress.habitId);

    if (habitIndex == -1) return;

    _habits[habitIndex].progress.add(todayProgress);
    notifyListeners();
  }
}
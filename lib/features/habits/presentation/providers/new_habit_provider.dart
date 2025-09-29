import 'package:find_your_mind/features/habits/domain/entities/type_habit.dart';
import 'package:flutter/material.dart';

class NewHabitProvider extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
  int _dailyGoal = 1;
  bool _isSelectedTypeHabit = false;
  String _selectedIcon = 'assets/icons/mind.svg';
  TypeHabit _typeHabitSelected = TypeHabit.none;

  int get dailyGoal => _dailyGoal;
  bool get isSelectedTypeHabit => _isSelectedTypeHabit;
  String get selectedIcon => _selectedIcon;
  TypeHabit get typeHabitSelected => _typeHabitSelected;

  void setTypeHabit(TypeHabit type) {
    _typeHabitSelected = type;
    _isSelectedTypeHabit = true;
    notifyListeners();
  }

  void clearTypeHabit() {
    _typeHabitSelected = TypeHabit.none;
    _isSelectedTypeHabit = false;
    notifyListeners();
  }

  void clear() {
    titleController.clear();
    descriptionController.clear();
    _dailyGoal = 1;
    _isSelectedTypeHabit = false;
    _selectedIcon = 'assets/icons/mind.svg';
    _typeHabitSelected = TypeHabit.none;
    notifyListeners();
  }

  void setDailyGoal(int goal) {
    if (goal < 1) return;

    _dailyGoal = goal;
    notifyListeners();
  }

  bool isTypeSelected(TypeHabit type) {
    return _typeHabitSelected == type;
  }

  void setSelectedIcon(String iconPath) {
    _selectedIcon = iconPath;
    notifyListeners();
  }
}
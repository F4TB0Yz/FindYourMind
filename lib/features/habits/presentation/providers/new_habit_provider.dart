import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:flutter/material.dart';

class NewHabitProvider extends ChangeNotifier {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  int _targetValue = 1;
  String _selectedIcon = '🧠';
  HabitCategory _selectedCategory = HabitCategory.none;
  HabitTrackingType _trackingType = HabitTrackingType.single;

  int get targetValue => _targetValue;
  String get selectedIcon => _selectedIcon;
  HabitCategory get selectedCategory => _selectedCategory;
  HabitTrackingType get trackingType => _trackingType;
  bool get hasSelectedCategory => _selectedCategory != HabitCategory.none;

  void setCategory(HabitCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearCategory() {
    _selectedCategory = HabitCategory.none;
    notifyListeners();
  }

  void clear() {
    titleController.clear();
    descriptionController.clear();
    _targetValue = 1;
    _selectedIcon = '🧠';
    _selectedCategory = HabitCategory.none;
    _trackingType = HabitTrackingType.single;
    notifyListeners();
  }

  void setTrackingType(HabitTrackingType type) {
    _trackingType = type;
    _targetValue = switch (type) {
      HabitTrackingType.single => 1,
      HabitTrackingType.timed => 600,
      HabitTrackingType.counter => 5,
    };
    notifyListeners();
  }

  void setTargetValue(int value) {
    if (value < 1) return;
    _targetValue = value;
    notifyListeners();
  }

  bool isCategorySelected(HabitCategory category) {
    return _selectedCategory == category;
  }

  void setSelectedIcon(String icon) {
    _selectedIcon = icon;
    notifyListeners();
  }
}

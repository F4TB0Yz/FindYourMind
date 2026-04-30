import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';

class HabitCategoryModel {
  static HabitCategory fromString(String category) {
    switch (category) {
      case 'health':
        return HabitCategory.health;
      case 'personal':
        return HabitCategory.personal;
      case 'productivity':
        return HabitCategory.productivity;
      case 'other':
        return HabitCategory.other;
      case 'none':
      default:
        return HabitCategory.none;
    }
  }

  static String toStringValue(HabitCategory category) {
    switch (category) {
      case HabitCategory.health:
        return 'health';
      case HabitCategory.personal:
        return 'personal';
      case HabitCategory.productivity:
        return 'productivity';
      case HabitCategory.other:
        return 'other';
      case HabitCategory.none:
        return 'none';
    }
  }
}

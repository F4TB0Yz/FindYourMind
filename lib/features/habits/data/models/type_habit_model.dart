import 'package:find_your_mind/features/habits/domain/entities/type_habit.dart';

class TypeHabitModel {
  String health = 'health';
  String personal = 'personal';
  String productivity = 'productivity';
  String other = 'other';
  String none = 'none';

  static TypeHabit fromString(String type) {
    switch (type) {
      case 'health':
        return TypeHabit.health;
      case 'personal':
        return TypeHabit.personal;
      case 'productivity':
        return TypeHabit.productivity;
      case 'other':
        return TypeHabit.other;
      case 'none':
        return TypeHabit.none;
      default:
        return TypeHabit.none;
    }
  }

  static String typeToString(TypeHabit type) {
    switch (type) {
      case TypeHabit.health:
        return 'health';
      case TypeHabit.personal:
        return 'personal';
      case TypeHabit.productivity:
        return 'productivity';
      case TypeHabit.other:
        return 'other';
      case TypeHabit.none:
        return 'none';
    }
  }
}
import 'package:find_your_mind/core/database/app_database.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';

class HabitLogModel {
  final String id;
  final String habitId;
  final String date;
  final int value;

  const HabitLogModel({
    required this.id,
    required this.habitId,
    required this.date,
    required this.value,
  });

  factory HabitLogModel.fromJson(Map<String, dynamic> json) {
    return HabitLogModel(
      id: json['id'] as String,
      habitId: json['habit_id'] as String,
      date: json['date'] as String,
      value: json['value'] as int,
    );
  }

  factory HabitLogModel.fromDrift(HabitLogsTableData row) {
    return HabitLogModel(
      id: row.id,
      habitId: row.habitId,
      date: row.date,
      value: row.value,
    );
  }

  HabitLog toEntity() {
    return HabitLog(
      id: id,
      habitId: habitId,
      date: date,
      value: value,
    );
  }
}

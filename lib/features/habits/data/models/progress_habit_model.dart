import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';

class ProgressHabitModel {
  final String id;
  final String habitId;
  final String date;
  final int dailyGoal;
  final int dailyCounter;

  const ProgressHabitModel({
    required this.id,
    required this.habitId,
    required this.date,
    required this.dailyGoal,
    required this.dailyCounter
  });

  factory ProgressHabitModel.fromJson(Map<String, dynamic> json) {
    return ProgressHabitModel(
      id: json['id'],
      habitId: json['habitId'],
      date: json['date'],
      dailyGoal: json['dailyGoal'],
      dailyCounter: json['dailyCounter'],
    );
  }

  HabitProgress toEntity() {
    return HabitProgress(
      id: id,
      habitId: habitId,
      date: date,
      dailyGoal: dailyGoal,
      dailyCounter: dailyCounter,
    );
  }
}
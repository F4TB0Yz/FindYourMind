import 'package:find_your_mind/features/habits/data/models/type_habit_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';

class ItemHabitModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String iconString;
  final DateTime createdAt;
  final String typeHabit;
  final int dailyGoal;
  final List<HabitProgress> progress;

  ItemHabitModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.typeHabit,
    required this.iconString,
    required this.dailyGoal,
    required this.progress
  });

  HabitEntity toEntity() {
    final typeHabitEntity = TypeHabitModel.fromString(typeHabit);

    return HabitEntity(
      id: id,
      userId: userId,
      title: title,
      description: description,
      icon: iconString,
      type: typeHabitEntity,
      dailyGoal: dailyGoal,
      initialDate: createdAt.toIso8601String(),
      progress: progress
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': description,
      'created_at': createdAt.toIso8601String(),
      'typeHabit': typeHabit,
      'iconString': iconString,
    };
  }

  factory ItemHabitModel.fromJson(Map<String, dynamic> json) {
    final List<Map<String, dynamic>> progressJsonList = json['progress'];
    final List<HabitProgress> progressEntityList = progressJsonList.map(
      (item) => HabitProgress(
        id: item['id'],
        habitId: item['habit_id'],
        date: item['date'],
        dailyGoal: item['daily_goal'],
        dailyCounter: item['daily_counter']
      )
    ).toList();

    return ItemHabitModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['initial_date'] as String),
      typeHabit: json['type'] as String,
      iconString: json['icon'] as String,
      dailyGoal: json['daily_goal'] as int,
      progress: progressEntityList
    );
  }
}
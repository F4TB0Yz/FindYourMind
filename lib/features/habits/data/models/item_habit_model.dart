import 'package:find_your_mind/features/habits/data/models/habit_category_model.dart';
import 'package:find_your_mind/features/habits/data/models/habit_log_model.dart';
import 'package:find_your_mind/features/habits/data/models/habit_tracking_type_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';

class ItemHabitModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String iconString;
  final DateTime createdAt;
  final String category;
  final String trackingType;
  final int targetValue;
  final List<HabitLog> logs;

  ItemHabitModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.createdAt,
    required this.category,
    required this.trackingType,
    required this.iconString,
    required this.targetValue,
    required this.logs,
  });

  HabitEntity toEntity() {
    return HabitEntity(
      id: id,
      userId: userId,
      title: title,
      description: description,
      icon: iconString,
      category: HabitCategoryModel.fromString(category),
      trackingType: HabitTrackingTypeModel.fromString(trackingType),
      targetValue: targetValue,
      initialDate: createdAt.toIso8601String(),
      logs: logs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': description,
      'created_at': createdAt.toIso8601String(),
      'category': category,
      'tracking_type': trackingType,
      'iconString': iconString,
      'target_value': targetValue,
    };
  }

  factory ItemHabitModel.fromJson(Map<String, dynamic> json) {
    final logsJsonList = (json['logs'] as List<dynamic>?)
      ?.map((item) => Map<String, dynamic>.from(item as Map))
      .toList() ?? [];

    final List<HabitLog> logEntityList = logsJsonList
        .map((item) => HabitLogModel.fromJson(item).toEntity())
        .toList();

    return ItemHabitModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse((json['created_at'] ?? json['initial_date']) as String),
      category: (json['category'] ?? 'none') as String,
      trackingType: (json['tracking_type'] ?? 'single') as String,
      iconString: json['icon'] as String,
      targetValue: (json['target_value'] ?? 1) as int,
      logs: logEntityList,
    );
  }
}

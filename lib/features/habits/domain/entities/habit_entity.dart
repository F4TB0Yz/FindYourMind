import 'package:equatable/equatable.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';

class HabitEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String icon;
  final HabitCategory category;
  final HabitTrackingType trackingType;
  final int targetValue;
  final String initialDate;
  final List<HabitLog> logs;

  const HabitEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.trackingType,
    required this.targetValue,
    required this.initialDate,
    required this.logs,
  });

  HabitEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? icon,
    HabitCategory? category,
    HabitTrackingType? trackingType,
    int? targetValue,
    String? initialDate,
    List<HabitLog>? logs,
  }) {
    return HabitEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      category: category ?? this.category,
      trackingType: trackingType ?? this.trackingType,
      targetValue: targetValue ?? this.targetValue,
      initialDate: initialDate ?? this.initialDate,
      logs: logs ?? this.logs,
    );
  }

  // Calcular días transcurridos
  int get daysSinceStart =>
      DateTime.now().difference(DateTime.parse(initialDate)).inDays;

  // Calcular semanas transcurridas
  int get weeksSinceStart => (daysSinceStart / 7).floor();

  // Formato amigable del tiempo transcurrido
  String get timeSinceStart {
    final now = DateTime.now();
    final start = DateTime.parse(initialDate);
    final difference = now.difference(start);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} s';
    }

    if (difference.inMinutes < 60) {
      final seconds = difference.inSeconds % 60;
      return '${difference.inMinutes} m $seconds s';
    }

    if (difference.inHours < 24) {
      final minutes = difference.inMinutes % 60;
      return '${difference.inHours} h $minutes m';
    }

    if (difference.inDays == 1) {
      return '1 día';
    }

    if (difference.inDays < 7) {
      return '${difference.inDays} días';
    }

    if (difference.inDays < 14) {
      return '1 semana';
    }

    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks semanas';
    }

    int months = (now.year - start.year) * 12 + now.month - start.month;
    if (now.day < start.day) {
      months--;
    }

    if (months == 1) {
      return '1 mes';
    }

    if (months < 12) {
      return '$months meses';
    }

    final years = (months / 12).floor();
    final remainingMonths = months % 12;
    if (remainingMonths == 0) {
      if (years == 1) {
        return '1 año';
      }

      return '$years años';
    } else {
      return '$years años $remainingMonths m';
    }
  }

  HabitLog? get todayLog {
    final now = DateTime.now();
    final date =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    for (final log in logs) {
      if (log.date.startsWith(date)) {
        return log;
      }
    }

    return null;
  }

  int get todayValue => todayLog?.value ?? 0;

  bool get isCompletedToday => todayValue >= targetValue;

  int get completedDaysCount {
    final completedDates = <String>{};

    for (final log in logs) {
      if (log.value >= targetValue) {
        completedDates.add(log.date.substring(0, 10));
      }
    }

    return completedDates.length;
  }

  double get completionRate {
    final totalDays = daysSinceStart + 1;

    if (totalDays <= 0) {
      return 0;
    }

    return completedDaysCount / totalDays * 100;
  }

  int get longestStreak {
    if (logs.isEmpty) {
      return 0;
    }

    final completedDates = <DateTime>{};

    for (final log in logs) {
      if (log.value < targetValue) {
        continue;
      }

      final date = DateTime.parse(log.date);
      completedDates.add(DateTime(date.year, date.month, date.day));
    }

    if (completedDates.isEmpty) {
      return 0;
    }

    final orderedDates = completedDates.toList()
      ..sort((left, right) => left.compareTo(right));

    var bestStreak = 1;
    var currentStreak = 1;

    for (var i = 1; i < orderedDates.length; i++) {
      final previousDate = orderedDates[i - 1];
      final currentDate = orderedDates[i];
      final difference = currentDate.difference(previousDate).inDays;

      if (difference == 1) {
        currentStreak++;
        if (currentStreak > bestStreak) {
          bestStreak = currentStreak;
        }
      } else {
        currentStreak = 1;
      }
    }

    return bestStreak;
  }

  int get streak {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    String format(DateTime date) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    bool completedOn(DateTime date) {
      final expectedDate = format(date);

      for (final log in logs) {
        if (log.date.startsWith(expectedDate)) {
          return log.value >= targetValue;
        }
      }

      return false;
    }

    int count = 0;
    final start = completedOn(today) ? 0 : 1;

    for (int i = start; i <= logs.length; i++) {
      if (!completedOn(today.subtract(Duration(days: i)))) {
        break;
      }
      count++;
    }

    return count;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    icon,
    category,
    trackingType,
    targetValue,
    initialDate,
    logs,
  ];
}

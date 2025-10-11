import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/entities/type_habit.dart';

class HabitEntity {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String icon;
  final TypeHabit type;
  final int dailyGoal;
  final String initialDate;
  final List<HabitProgress> progress;

  HabitEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.dailyGoal,
    required this.initialDate,
    required this.progress
  });

  HabitEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    String? icon,
    TypeHabit? type,
    int? dailyGoal,
    String? initialDate,
    List<HabitProgress>? progress
  }) {
    return HabitEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      initialDate: initialDate ?? this.initialDate,
      progress: progress ?? this.progress
    );
  }

  // Calcular días transcurridos
  int get daysSinceStart => DateTime.now().difference(DateTime.parse(initialDate)).inDays;
  
  // Calcular semanas transcurridas
  int get weeksSinceStart => (daysSinceStart / 7).floor();
  
  // Formato amigable del tiempo transcurrido
  String get timeSinceStart {
    final now = DateTime.now();
    final start = DateTime.parse(initialDate);
    final difference = now.difference(start);

    // Si han pasado menos de un minuto (60 segundos)
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds} s';
    }
    
    // Si han pasado menos de una hora (60 minutos)
    if (difference.inMinutes < 60) {
      final seconds = difference.inSeconds % 60;
      return '${difference.inMinutes} m $seconds s';
    }
    
    // Si han pasado menos de un día (24 horas)
    if (difference.inHours < 24) {
      final minutes = difference.inMinutes % 60;
      return '${difference.inHours} h $minutes m';
    }

    if (difference.inDays == 1) {
      return '1 día';
    }
    
    // Si han pasado menos de una semana (7 días)
    if (difference.inDays < 7) {
      return '${difference.inDays} días';
    }

    if (difference.inDays < 14) {
      return '1 semana';
    }
    
    // Si han pasado menos de un mes (aproximadamente 30 días)
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks semanas';
    }
    
    // Calcular meses
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
    
    // Han pasado años
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
}
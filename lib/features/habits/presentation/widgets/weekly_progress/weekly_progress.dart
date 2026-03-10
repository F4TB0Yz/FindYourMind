import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/weekly_progress/pulsing_today_indicator.dart';
import 'package:flutter/material.dart';

/// Muestra el progreso de los 7 días de la semana actual para un hábito.
///
/// Días completados: círculo con borde verde. Días fallidos: borde rojo apagado.
/// Días futuros de la semana: borde sutil gris sin connotación negativa.
/// El día actual usa un indicador pulsante animado.
class WeeklyProgress extends StatelessWidget {
  final HabitEntity habit;

  const WeeklyProgress({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    const weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final today = DateTime.now();
    final todayString = today.toIso8601String().substring(0, 10);
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final dateString = date.toIso8601String().substring(0, 10);
        final isFuture = date.isAfter(today) && dateString != todayString;

        final progress = habit.progress.firstWhere(
          (p) => p.date == dateString,
          orElse: () => HabitProgress(
            id: '',
            habitId: habit.id,
            date: dateString,
            dailyGoal: habit.dailyGoal,
            dailyCounter: 0,
          ),
        );

        final isCompleted = progress.dailyCounter >= habit.dailyGoal;
        final isToday = dateString == todayString;

        return _WeekDayColumn(
          label: weekDays[index],
          day: date.day,
          isToday: isToday,
          isCompleted: isCompleted,
          isFuture: isFuture,
        );
      }),
    );
  }
}

/// Columna con la letra del día y el indicador circular.
class _WeekDayColumn extends StatelessWidget {
  final String label;
  final int day;
  final bool isToday;
  final bool isCompleted;
  final bool isFuture;

  const _WeekDayColumn({
    required this.label,
    required this.day,
    required this.isToday,
    required this.isCompleted,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    final Color labelColor = isToday
        ? (isCompleted ? AppColors.successMuted : AppColors.dangerMuted)
        : AppColors.textMuted;

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: labelColor,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        isToday
            ? PulsingTodayIndicator(day: day, isCompleted: isCompleted)
            : _DayCircle(day: day, isCompleted: isCompleted, isFuture: isFuture),
      ],
    );
  }
}

/// Círculo indicador para días pasados o futuros (no el día actual).
class _DayCircle extends StatelessWidget {
  final int day;
  final bool isCompleted;
  final bool isFuture;

  const _DayCircle({
    required this.day,
    required this.isCompleted,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    final Color borderColor = isFuture
        ? AppColors.borderSubtle
        : isCompleted
            ? AppColors.successMuted
            : AppColors.dangerMuted.withValues(alpha: 0.6);

    final Color bgColor = isFuture
        ? Colors.transparent
        : isCompleted
            ? AppColors.successMuted.withValues(alpha: 0.1)
            : Colors.transparent;

    final Color textColor = isFuture
        ? AppColors.textMuted
        : isCompleted
            ? AppColors.successMuted
            : AppColors.dangerMuted.withValues(alpha: 0.8);

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 13,
            color: textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
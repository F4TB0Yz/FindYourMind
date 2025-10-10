import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/weekly_progress/pulsing_today_indicator.dart';
import 'package:flutter/material.dart';

class WeeklyProgress extends StatelessWidget {
  final HabitEntity habit;

  const WeeklyProgress({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return _buildWeekView();
  }

   Widget _buildWeekView() {
    final List<String> weekDays = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final DateTime today = DateTime.now();
    final DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (index) {
        final date = startOfWeek.add(Duration(days: index));
        final dateString = date.toIso8601String().substring(0, 10);
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
        final isToday = dateString == today.toIso8601String().substring(0, 10);

        return Column(
          children: [
            Text(
              weekDays[index],
              style: TextStyle(
                fontSize: 14,
                color: isToday 
                    ? (isCompleted ? const Color(0xFF00FF41) : const Color(0xFFFF1744))
                    : Colors.white38,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            isToday
                ? _buildTodayIndicator(date.day, isCompleted)
                : _buildNormalDayIndicator(date.day, isCompleted),
          ],
        );
      }),
    );
  }

  Widget _buildTodayIndicator(int day, bool isCompleted) {
    return PulsingTodayIndicator(
      day: day,
      isCompleted: isCompleted,
    );
  }

  Widget _buildNormalDayIndicator(int day, bool isCompleted) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.red.withValues(alpha: 0.3),
        border: Border.all(
          color: isCompleted ? Colors.green : Colors.red,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 14,
            color: isCompleted ? Colors.green : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
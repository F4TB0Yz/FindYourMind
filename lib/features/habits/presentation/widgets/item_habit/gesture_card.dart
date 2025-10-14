import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class GestureCardHabitItem extends StatelessWidget {
  final HabitEntity habit;
  final String timeSinceStart;
  final int counterToday;
  final int dailyGoal;
  final bool isFlashingRed;
  final bool isFlashingGreen;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const GestureCardHabitItem({
    super.key,
    required this.habit,
    required this.timeSinceStart,
    required this.counterToday,
    required this.dailyGoal,
    required this.isFlashingRed,
    required this.isFlashingGreen,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          color: isFlashingRed
              ? Colors.red.withValues(alpha: 0.65)
              : isFlashingGreen
                  ? Colors.green.withValues(alpha: 0.65)
                  : AppColors.darkBackground,
          boxShadow: isFlashingGreen || isFlashingRed
              ? [
                  BoxShadow(
                    color: isFlashingGreen 
                        ? Colors.green.withValues(alpha: 0.3)
                        : Colors.red.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              habit.icon,
              width: 42,
              height: 42,
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    habit.title,
                    overflow: TextOverflow.clip,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$counterToday de $dailyGoal completados',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white30,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(width: 20),

            FittedBox(
              child: Text(
                timeSinceStart,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 63, 243, 18),
                  fontWeight: FontWeight.w500
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
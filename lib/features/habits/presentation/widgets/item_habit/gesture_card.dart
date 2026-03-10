import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Card visual de un hábito en la lista principal.
///
/// Muestra ícono, título, barra de progreso y tiempo desde el inicio.
/// Responde visualmente al toque (flash verde) y long press (flash rojo).
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
    final bool isFlashing = isFlashingRed || isFlashingGreen;
    final double progress = dailyGoal > 0
        ? (counterToday / dailyGoal).clamp(0.0, 1.0)
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        width: double.infinity,
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          color: isFlashingGreen
              ? AppColors.successMuted.withValues(alpha: 0.25)
              : isFlashingRed
                  ? AppColors.dangerMuted.withValues(alpha: 0.25)
                  : AppColors.darkBackground,
          border: Border.all(
            color: isFlashingGreen
                ? AppColors.successMuted.withValues(alpha: 0.45)
                : isFlashingRed
                    ? AppColors.dangerMuted.withValues(alpha: 0.45)
                    : AppColors.borderSubtle,
            width: 1,
          ),
          boxShadow: isFlashing
              ? [
                  BoxShadow(
                    color: isFlashingGreen
                        ? AppColors.successMuted.withValues(alpha: 0.12)
                        : AppColors.dangerMuted.withValues(alpha: 0.12),
                    blurRadius: 6,
                  ),
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              habit.icon,
              width: 36,
              height: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _HabitCardContent(
                title: habit.title,
                progress: progress,
                counterToday: counterToday,
                dailyGoal: dailyGoal,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              timeSinceStart,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Título y barra de progreso del hábito.
class _HabitCardContent extends StatelessWidget {
  final String title;
  final double progress;
  final int counterToday;
  final int dailyGoal;

  const _HabitCardContent({
    required this.title,
    required this.progress,
    required this.counterToday,
    required this.dailyGoal,
  });

  @override
  Widget build(BuildContext context) {
    final bool isComplete = progress >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        _ProgressBar(progress: progress, isComplete: isComplete),
      ],
    );
  }
}

/// Barra de progreso lineal del hábito.
class _ProgressBar extends StatelessWidget {
  final double progress;
  final bool isComplete;

  const _ProgressBar({required this.progress, required this.isComplete});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Track
            Container(
              height: 2,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: AppColors.borderSubtle,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            // Fill
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              height: 2,
              width: constraints.maxWidth * progress,
              decoration: BoxDecoration(
                color: isComplete
                    ? AppColors.successMuted
                    : AppColors.accentText.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        );
      },
    );
  }
}
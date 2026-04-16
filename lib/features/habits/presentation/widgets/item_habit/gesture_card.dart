import 'dart:math' as math;
import 'dart:ui';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/config/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

/// Card visual de un hábito en la lista principal con Glassmorfismo y efectos.
import 'package:find_your_mind/shared/presentation/widgets/animations/particle_explosion.dart';

class GestureCardHabitItem extends StatelessWidget {
  final HabitEntity habit;
  final String timeSinceStart;
  final int counterToday;
  final int dailyGoal;
  final bool isFlashingRed;
  final bool isFlashingGreen;
  final bool triggerCompletion;
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
    required this.triggerCompletion,
    required this.onTap,
    required this.onLongPress,
  });

  bool get _isAtRisk {
    final now = DateTime.now();
    final double progress = dailyGoal > 0 ? counterToday / dailyGoal : 0;
    
    // Si no ha empezado y ya es tarde (después de las 6 PM)
    if (counterToday == 0 && now.hour >= 18) return true;
    
    // Si lleva menos del 50% y es muy tarde (después de las 10 PM)
    if (progress < 0.5 && now.hour >= 22) return true;
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isFlashing = isFlashingRed || isFlashingGreen;
    final double progress = dailyGoal > 0
        ? (counterToday / dailyGoal).clamp(0.0, 1.0)
        : 0.0;
    final bool isComplete = progress >= 1.0;
    final bool atRisk = _isAtRisk;

    return ParticleExplosion(
      trigger: triggerCompletion,
      child: AnimatedScale(
        scale: triggerCompletion ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: _ShakeWidget(
          active: atRisk && !isComplete,
          child: GestureDetector(
            onTap: onTap,
            onLongPress: onLongPress,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isFlashingGreen
                        ? cs.tertiary.withValues(alpha: 0.3)
                        : isFlashingRed
                            ? cs.error.withValues(alpha: 0.3)
                            : atRisk && !isComplete
                                ? Colors.black.withValues(alpha: 0.4)
                                : cs.surface.withValues(alpha: 0.7),
                    border: Border.all(
                      color: isFlashingGreen
                          ? cs.tertiary.withValues(alpha: 0.6)
                          : isFlashingRed
                              ? cs.error.withValues(alpha: 0.6)
                              : isComplete
                                  ? cs.tertiary.withValues(alpha: 0.5)
                                  : cs.outlineVariant.withValues(alpha: 0.5),
                      width: isComplete ? 1.5 : 1,
                    ),
                    boxShadow: [
                      if (isComplete)
                        BoxShadow(
                          color: cs.tertiary.withValues(alpha: 0.15),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      if (isFlashing)
                        BoxShadow(
                          color: isFlashingGreen
                              ? cs.tertiary.withValues(alpha: 0.2)
                              : cs.error.withValues(alpha: 0.2),
                          blurRadius: 8,
                        ),
                    ],
                  ),
                  child: Opacity(
                    opacity: atRisk && !isComplete ? 0.7 : 1.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          habit.icon,
                          width: 38,
                          height: 38,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _HabitCardContent(
                            title: habit.title,
                            progress: progress,
                            counterToday: counterToday,
                            dailyGoal: dailyGoal,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$counterToday/$dailyGoal',
                              style: AppTextStyles.counter(context).copyWith(
                                fontSize: 13,
                                color: isComplete ? cs.tertiary : cs.primary,
                              ),
                            ),
                            Text(
                              timeSinceStart,
                              style: AppTextStyles.timerSmall(context).copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget interno para la vibración visual (Aversión a la pérdida).
class _ShakeWidget extends StatelessWidget {
  final Widget child;
  final bool active;

  const _ShakeWidget({required this.child, required this.active});

  @override
  Widget build(BuildContext context) {
    if (!active) return child;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        final double offset = math.sin(value * math.pi * 10) * 1.5;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: child,
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
          style: AppTextStyles.titleLarge(context).copyWith(fontSize: 15),
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
    final cs = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Track
            Container(
              height: 2,
              width: constraints.maxWidth,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
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
                    ? cs.tertiary
                    : cs.primary.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        );
      },
    );
  }
}
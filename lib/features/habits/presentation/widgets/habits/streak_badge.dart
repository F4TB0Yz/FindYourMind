import 'package:flutter/material.dart';

class StreakBadge extends StatelessWidget {
  const StreakBadge({
    required this.streakDays,
    super.key,
  });

  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF3C282),
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF92400d).withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: Text(
            '🔥 ${streakDays}d',
            key: ValueKey<int>(streakDays),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF92400d),
                  fontSize: 13,
                ),
          ),
        ),
      ),
    );
  }
}

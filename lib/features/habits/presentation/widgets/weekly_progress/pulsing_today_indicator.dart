import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

/// Indicador pulsante para el día actual en el progreso semanal.
///
/// Anima la opacidad del borde entre 0.5 y 1.0.
/// Sin sombras neón — solo un borde animado sobrio.
class PulsingTodayIndicator extends StatefulWidget {
  final int day;
  final bool isCompleted;

  const PulsingTodayIndicator({
    super.key,
    required this.day,
    required this.isCompleted,
  });

  @override
  State<PulsingTodayIndicator> createState() => _PulsingTodayIndicatorState();
}

class _PulsingTodayIndicatorState extends State<PulsingTodayIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color borderColor = widget.isCompleted
        ? AppColors.successMuted
        : AppColors.dangerMuted;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isCompleted
                ? AppColors.successMuted.withValues(alpha: 0.12)
                : AppColors.dangerMuted.withValues(alpha: 0.08),
            border: Border.all(
              color: borderColor.withValues(alpha: _animation.value),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: borderColor.withValues(alpha: 0.15 * _animation.value),
                blurRadius: 4,
              ),
            ],
          ),
          child: child,
        );
      },
      child: Center(
        child: Text(
          '${widget.day}',
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
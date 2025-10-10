import 'package:flutter/material.dart';

class PulsingTodayIndicator extends StatefulWidget {
  final int day;
  final bool isCompleted;

  const PulsingTodayIndicator({
    super.key, 
    required this.day,
    required this.isCompleted,
  });

  @override
  State<PulsingTodayIndicator> createState() => PulsingTodayIndicatorState();
}

class PulsingTodayIndicatorState extends State<PulsingTodayIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Color dinámico según si está completado o no
    final Color neonColor = widget.isCompleted 
        ? const Color(0xFF00FF41)  // Verde neón si está completado
        : const Color(0xFFFF1744);  // Rojo neón si NO está completado
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.isCompleted
                ? Colors.green.withValues(alpha: 0.3)
                : Colors.red.withValues(alpha: 0.3),
            border: Border.all(
              color: neonColor,
              width: 1.5 * _animation.value,
            ),
            boxShadow: [
              // Sombra interior más intensa
              BoxShadow(
                color: neonColor.withValues(alpha: 0.4 * _animation.value),
                blurRadius: 8 * _animation.value,
                spreadRadius: 1.5 * _animation.value,
              ),
              // Sombra exterior brillante
              BoxShadow(
                color: neonColor.withValues(alpha: 0.25 * _animation.value),
                blurRadius: 16 * _animation.value,
                spreadRadius: 3 * _animation.value,
              ),
              // Sombra extra para más resplandor
              BoxShadow(
                color: neonColor.withValues(alpha: 0.15 * _animation.value),
                blurRadius: 24 * _animation.value,
                spreadRadius: 4 * _animation.value,
              ),
            ],
          ),
          child: Center(
            child: Text(
              '${widget.day}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                shadows: [
                  Shadow(
                    color: neonColor.withValues(alpha: 0.6 * _animation.value),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
import 'package:flutter/material.dart';

/// Widget que proporciona transiciones animadas entre pantallas
class AnimatedScreenTransition extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const AnimatedScreenTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        // Transición de fade + slide
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0.1, 0.0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeIn,
        ));

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: fadeAnimation,
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(child.runtimeType.toString()),
        child: child,
      ),
    );
  }
}

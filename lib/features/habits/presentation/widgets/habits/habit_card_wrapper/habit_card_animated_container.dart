import 'package:flutter/material.dart';

class HabitCardAnimatedContainer extends StatelessWidget {
  const HabitCardAnimatedContainer({
    required this.habitId,
    required this.isVisible,
    required this.shouldFade,
    required this.shouldSlideBack,
    required this.isTimed,
    required this.onLongPress,
    required this.child,
    super.key,
  });

  final String habitId;
  final bool isVisible;
  final bool shouldFade;
  final bool shouldSlideBack;
  final bool isTimed;
  final VoidCallback onLongPress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final animated = AnimatedOpacity(
      key: ValueKey(habitId),
      opacity: shouldFade || shouldSlideBack ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeIn,
      child: AnimatedSlide(
        offset: shouldFade
            ? const Offset(0.0, -0.12)
            : shouldSlideBack
                ? const Offset(0.12, 0.0)
                : Offset.zero,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        child: GestureDetector(
          onLongPress: onLongPress,
          child: child,
        ),
      ),
    );

    if (isTimed) {
      return Offstage(
        key: ValueKey('os_$habitId'),
        offstage: !isVisible,
        child: animated,
      );
    }

    if (!isVisible) return const SizedBox.shrink();
    return animated;
  }
}

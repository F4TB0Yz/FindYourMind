import 'package:flutter/material.dart';

/// Ítem individual del bottom navigation bar.
/// Estado activo indicado por color del ícono y punto azul debajo.
/// Desacoplado de ScreensProvider — recibe [index] y [currentIndex].
class CustomItemBar extends StatelessWidget {
  final IconData icon;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const CustomItemBar({
    super.key,
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 64,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFF58a6ff)
                  : const Color(0xFF8b949e),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF58a6ff)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
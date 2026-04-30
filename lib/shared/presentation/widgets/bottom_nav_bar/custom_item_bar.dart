import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Ítem individual del bottom navigation bar.
/// Estado activo indicado por color del ícono y punto azul debajo.
/// Desacoplado de ScreensProvider — recibe [index] y [currentIndex].
class CustomItemBar extends StatelessWidget {
  final String text;
  final List<List<dynamic>> icon;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  const CustomItemBar({
    super.key,
    required this.text,
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = currentIndex == index;

    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 64,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: icon,
              size: 24,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
            const SizedBox(height: 5),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

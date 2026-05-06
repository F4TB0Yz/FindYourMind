import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SheetTabToggle extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SheetTabToggle({
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color selectedTextColor = isDark
        ? Colors.black.withValues(alpha: 0.88)
        : cs.onSurface;
    final Color unselectedTextColor = isDark
        ? Colors.black.withValues(alpha: 0.62)
        : cs.onSurfaceVariant.withValues(alpha: 0.7);

    // Container con fondo y borde redondeado
    return Container(
      height: 38,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      // Stack para colocar el fondo animado y los textos encima
      child: Stack(
        children: [
          // Fondo animado que se mueve según el índice seleccionado
          AnimatedAlign(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            alignment: Alignment(
              -1.0 + (selectedIndex * (2.0 / (labels.length - 1))),
              0,
            ),
            child: FractionallySizedBox(
              widthFactor: 1 / labels.length,
              child: Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0x00F6F3A0).withValues(alpha: 0.6)
                      : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: List.generate(
              labels.length,
              (index) => Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(index),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Center(
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 180),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: selectedIndex == index
                              ? selectedTextColor
                              : unselectedTextColor,
                        ),
                        child: Text(labels[index]),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

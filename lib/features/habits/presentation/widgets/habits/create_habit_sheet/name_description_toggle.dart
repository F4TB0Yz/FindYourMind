import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NameDescriptionToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _labels = ['NOMBRE', 'DESCRIPCIÓN'];

  const NameDescriptionToggle({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.onSurface.withValues(alpha: 0.1)
                : const Color(0xFF5D6062).withValues(alpha: 0.23),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  alignment: selectedIndex == 0
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? colorScheme.surfaceContainerHigh
                            : const Color(0xFFF0E1C3),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.08,
                            ),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: List.generate(_labels.length, (i) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(i),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 14,
                        ),
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selectedIndex == i
                                  ? colorScheme.primary
                                  : (isDark
                                      ? colorScheme.onSurface
                                          .withValues(alpha: 0.6)
                                      : Colors.white),
                            ),
                            child: Text(_labels[i]),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

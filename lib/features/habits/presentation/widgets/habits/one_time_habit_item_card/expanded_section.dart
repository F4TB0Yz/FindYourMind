import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';

class ExpandedSection extends StatelessWidget {
  const ExpandedSection({
    required this.isExpanded,
    required this.habit,
    required this.cardFillColor,
    required this.expandedSectionFillColor,
    super.key,
  });

  final bool isExpanded;
  final HabitEntity habit;
  final Color cardFillColor;
  final Color expandedSectionFillColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 180),
      crossFadeState:
          isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      firstChild: const SizedBox(width: double.infinity, height: 0),
      firstCurve: Curves.easeOut,
      secondCurve: Curves.easeOut,
      sizeCurve: Curves.easeOut,
      secondChild: Column(
        children: [
          Divider(
            height: 1,
            thickness: 1,
            color: Color.alphaBlend(
              Colors.black.withValues(alpha: 0.12),
              cardFillColor,
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: expandedSectionFillColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: _MetricColumn(
                      title: 'RACHA',
                      value: '${habit.streak}d',
                      titleColor: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                  Expanded(
                    child: _MetricColumn(
                      title: 'MEJOR',
                      value: '${habit.longestStreak}d',
                      titleColor: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                  Expanded(
                    child: _MetricColumn(
                      title: 'CUMPLIDO',
                      value:
                          '${habit.completedDaysCount}/${habit.daysSinceStart + 1}',
                      titleColor: Colors.white.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn({
    required this.title,
    required this.value,
    required this.titleColor,
  });

  final String title;
  final String value;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white54 : const Color.fromARGB(255, 92, 86, 86).withValues(alpha: 0.88),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.fraunces(
            fontSize: 22,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : Colors.black.withValues(alpha: 0.88),
          ),
        ),
      ],
    );
  }
}

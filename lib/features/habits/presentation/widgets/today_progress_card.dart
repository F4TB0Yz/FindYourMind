import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TodayProgressCard extends StatelessWidget {
  const TodayProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    final TodayProgressSummary viewModel = context
        .select<HabitsProvider, TodayProgressSummary>(
          (provider) => provider.todayProgressSummary,
        );

    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color darkColor = const Color(
      0xFF135970,
    ).withValues(alpha: isDark ? 0.92 : 0.78);
    final Color lightColor = const Color(
      0xFF30B5CE,
    ).withValues(alpha: isDark ? 0.68 : 0.86);
    final Color totalHabitsColor = isDark
        ? const Color(0xFFD7EEF3)
        : const Color(0xFFB9F4FF);
    final int percentage = (viewModel.progress * 100).round();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [lightColor, darkColor],
          stops: const [0.0, 0.75],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TU PROGRESO HOY',
              style: textTheme.bodySmall?.copyWith(
                color: const Color(0xFFa8f4fb),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '${viewModel.completedHabits}/',
                        style: GoogleFonts.fraunces(
                          textStyle: textTheme.headlineMedium,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: '${viewModel.totalHabits}',
                        style: GoogleFonts.fraunces(
                          textStyle: textTheme.headlineSmall,
                          color: totalHabitsColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$percentage % completado',
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFFaaf4fb).withValues(alpha: 0.9),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: viewModel.progress,
                          backgroundColor: Colors.white.withValues(alpha: 0.42),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFa8f4fb),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

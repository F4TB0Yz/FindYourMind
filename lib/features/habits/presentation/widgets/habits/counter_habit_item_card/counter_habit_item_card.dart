import 'package:find_your_mind/config/theme/app_colors.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/one_time_habit_item_card/card_header.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class CounterHabitItemCard extends StatelessWidget {
  const CounterHabitItemCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.streakDays,
    required this.currentCount,
    required this.goalCount,
    required this.isExpanded,
    required this.onExpandTap,
    required this.onIncrement,
    required this.onDecrement,
    this.cardColor,
    super.key,
  });

  final String icon;
  final String title;
  final String description;
  final int streakDays;
  final int currentCount;
  final int goalCount;
  final bool isExpanded;
  final VoidCallback onExpandTap;
  final VoidCallback? onIncrement;
  final VoidCallback? onDecrement;
  final Color? cardColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedCardColor =
        cardColor ?? AppColors.oneTimeHabitCardColor(context);
    final emojiBoxColor = isDark
        ? Color.lerp(AppColors.darkSurfaceContainer, resolvedCardColor, 0.48)!
        : Color.alphaBlend(
            resolvedCardColor.withValues(alpha: 0.42),
            AppColors.lightSurfaceContainer,
          );
    final cardFillColor = isDark
        ? Color.lerp(AppColors.darkSurfaceContainer, resolvedCardColor, 0.34)!
        : Color.alphaBlend(
            resolvedCardColor.withValues(alpha: 0.56),
            AppColors.lightSurfaceContainer,
          );
    final expandedSectionFillColor = Color.alphaBlend(
      Colors.black.withValues(alpha: isDark ? 0.10 : 0.06),
      cardFillColor,
    );
    final cardBorderColor = isDark
        ? Color.lerp(AppColors.darkOnSurfaceVariant, resolvedCardColor, 0.18)!
            .withValues(alpha: 0.65)
        : resolvedCardColor.withValues(alpha: 0.72);
    final progress = goalCount == 0
        ? 0.0
        : (currentCount / goalCount).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onExpandTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, right: 12, left: 12),
        decoration: BoxDecoration(
          color: cardFillColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cardBorderColor, width: 2),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  CardHeader(
                    resolvedEmoji: icon.isNotEmpty ? icon : '🔢',
                    title: title,
                    description: description,
                    streakDays: streakDays,
                    isExpanded: isExpanded,
                    emojiBoxColor: emojiBoxColor,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: expandedSectionFillColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _RoundActionButton(
                              icon: HugeIcons.strokeRoundedMinusSign,
                              onTap: onDecrement,
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  Text(
                                    '$currentCount/$goalCount',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: progress,
                                      minHeight: 10,
                                      backgroundColor: Colors.black.withValues(alpha: 0.08),
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _RoundActionButton(
                              icon: HugeIcons.strokeRoundedAdd01,
                              onTap: onIncrement,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 180),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
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
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Text(
                      'Hoy: $currentCount de $goalCount repeticiones',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundActionButton extends StatelessWidget {
  final List<List<dynamic>> icon;
  final VoidCallback? onTap;

  const _RoundActionButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: onTap == null
              ? cs.surfaceContainerLow
              : cs.primary.withValues(alpha: 0.12),
          shape: BoxShape.circle,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Center(
          child: HugeIcon(
            icon: icon,
            size: 18,
            color: onTap == null ? cs.outline : cs.primary,
          ),
        ),
      ),
    );
  }
}

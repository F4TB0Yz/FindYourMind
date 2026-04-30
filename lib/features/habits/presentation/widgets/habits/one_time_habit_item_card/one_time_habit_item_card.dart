import 'package:flutter/material.dart';
import 'package:find_your_mind/config/theme/app_colors.dart';
import 'card_header.dart';
import 'complete_button.dart';
import 'expanded_section.dart';

class OneTimeHabitItemCard extends StatefulWidget {
  const OneTimeHabitItemCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.streakDays,
    required this.isCompleted,
    required this.isExpanded,
    required this.onExpandTap,
    this.cardColor,
    this.onMarkCompletedTap,
    this.shimmerBaseColor = const Color(0xFF66FFFF),
    this.shimmerHighlightColor = const Color(0xFFFFF3BF),
    super.key,
  });

  final String icon;
  final String title;
  final String description;
  final int streakDays;
  final bool isCompleted;
  final bool isExpanded;
  final VoidCallback onExpandTap;
  final Color? cardColor;
  final VoidCallback? onMarkCompletedTap;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;

  @override
  State<OneTimeHabitItemCard> createState() => _OneTimeHabitItemCardState();
}

class _OneTimeHabitItemCardState extends State<OneTimeHabitItemCard> {
  bool _isActionPressed = false;
  int _pressAnimationToken = 0;
  static const String _defaultEmoji = '🧠';

  void _setActionPressed(bool value) {
    if (_isActionPressed == value) return;
    setState(() => _isActionPressed = value);
  }

  void _playPressAnimation() {
    final int token = ++_pressAnimationToken;
    _setActionPressed(true);
    Future<void>.delayed(const Duration(milliseconds: 140)).then((_) {
      if (!mounted || token != _pressAnimationToken) return;
      _setActionPressed(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color resolvedCardColor =
        widget.cardColor ?? AppColors.oneTimeHabitCardColor(context);

    final Color emojiBoxColor = isDark
        ? Color.lerp(AppColors.darkSurfaceContainer, resolvedCardColor, 0.48)!
        : Color.alphaBlend(
            resolvedCardColor.withValues(alpha: 0.42),
            AppColors.lightSurfaceContainer,
          );
    final Color cardFillColor = isDark
        ? Color.lerp(AppColors.darkSurfaceContainer, resolvedCardColor, 0.34)!
        : Color.alphaBlend(
            resolvedCardColor.withValues(alpha: 0.56),
            AppColors.lightSurfaceContainer,
          );
    final Color expandedSectionFillColor = Color.alphaBlend(
      Colors.black.withValues(alpha: isDark ? 0.10 : 0.06),
      cardFillColor,
    );
    final Color cardBorderColor = isDark
        ? Color.lerp(
            AppColors.darkOnSurfaceVariant,
            resolvedCardColor,
            0.18,
          )!.withValues(alpha: 0.65)
        : resolvedCardColor.withValues(alpha: 0.72);

    final String resolvedEmoji =
        widget.icon.isNotEmpty ? widget.icon : _defaultEmoji;

    return Listener(
      onPointerDown: (_) => _playPressAnimation(),
      onPointerCancel: (_) {
        _pressAnimationToken++;
        _setActionPressed(false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onExpandTap,
        child: AnimatedScale(
          scale: _isActionPressed ? 0.985 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          child: Container(
            margin: const EdgeInsets.only(bottom: 10, right: 12, left: 12),
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: cardFillColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cardBorderColor, width: 2),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: resolvedCardColor.withValues(
                          alpha: _isActionPressed ? 0.10 : 0.14,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      CardHeader(
                        resolvedEmoji: resolvedEmoji,
                        title: widget.title,
                        description: widget.description,
                        streakDays: widget.streakDays,
                        isExpanded: widget.isExpanded,
                        emojiBoxColor: emojiBoxColor,
                      ),
                      const SizedBox(height: 12),
                      CompleteButton(
                        onMarkCompletedTap: widget.onMarkCompletedTap,
                        isCompleted: widget.isCompleted,
                        resolvedCardColor: resolvedCardColor,
                        cardBorderColor: cardBorderColor,
                        cardFillColor: cardFillColor,
                        isDark: isDark,
                        shimmerBaseColor: widget.shimmerBaseColor,
                        shimmerHighlightColor: widget.shimmerHighlightColor,
                      ),
                    ],
                  ),
                ),
                ExpandedSection(
                  isExpanded: widget.isExpanded,
                  cardFillColor: cardFillColor,
                  expandedSectionFillColor: expandedSectionFillColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:find_your_mind/config/theme/app_colors.dart';
import 'package:lucide_icons/lucide_icons.dart';

class OneTimeHabitItemCard extends StatefulWidget {
  const OneTimeHabitItemCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.streakDays,
    this.cardColor,
    this.onMarkCompletedTap,
    this.actionLabel = 'Marcar como completado',
    super.key,
  });

  final String emoji;
  final String title;
  final String description;
  final int streakDays;
  final Color? cardColor;
  final VoidCallback? onMarkCompletedTap;
  final String actionLabel;

  @override
  State<OneTimeHabitItemCard> createState() => _OneTimeHabitItemCardState();
}

class _OneTimeHabitItemCardState extends State<OneTimeHabitItemCard> {
  bool _isActionPressed = false;
  int _pressAnimationToken = 0;
  bool _isExpanded = false;

  void _setActionPressed(bool value) {
    if (_isActionPressed == value) {
      return;
    }

    setState(() {
      _isActionPressed = value;
    });
  }

  void _playPressAnimation() {
    final int token = ++_pressAnimationToken;

    _setActionPressed(true);
    Future<void>.delayed(const Duration(milliseconds: 140)).then((_) {
      if (!mounted || token != _pressAnimationToken) {
        return;
      }

      _setActionPressed(false);
    });
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
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
    final Color expandedSectionFillColor = isDark
        ? Color.lerp(AppColors.darkSurface, resolvedCardColor, 0.26)!
        : Color.alphaBlend(
            resolvedCardColor.withValues(alpha: 0.70),
            AppColors.lightSurfaceContainer,
          );
    final Color cardBorderColor = isDark
        ? Color.lerp(
            AppColors.darkOnSurfaceVariant,
            resolvedCardColor,
            0.18,
          )!.withValues(alpha: 0.65)
        : resolvedCardColor.withValues(alpha: 0.72);
    final Color completeButtonBorderColor = cardBorderColor;
    final Color completeButtonFillColor = isDark
        ? Color.lerp(AppColors.darkSurfaceContainer, resolvedCardColor, 0.28)!
        : Color.alphaBlend(
            resolvedCardColor.withValues(alpha: 0.18),
            AppColors.lightSurfaceContainer,
          );

    return Listener(
      onPointerDown: (_) => _playPressAnimation(),
      onPointerCancel: (_) {
        _pressAnimationToken++;
        _setActionPressed(false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleExpanded,
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
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: emojiBoxColor,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Center(
                              child: Text(
                                widget.emoji,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.description,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3C282),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Center(
                              child: Text(
                                '🔥 ${widget.streakDays}d',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF92400d),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            LucideIcons.chevronDown,
                            size: 18,
                            color: Color.fromARGB(255, 131, 152, 159),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapCancel: () {
                          _pressAnimationToken++;
                          _setActionPressed(false);
                        },
                        onTap: widget.onMarkCompletedTap,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 48),
                          padding: const EdgeInsets.symmetric(
                            vertical: 13,
                            horizontal: 11,
                          ),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: completeButtonFillColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              width: 2,
                              color: completeButtonBorderColor,
                            ),
                            boxShadow: isDark
                                ? null
                                : [
                                    BoxShadow(
                                      color: resolvedCardColor.withValues(
                                        alpha: 0.24,
                                      ),
                                      blurRadius: 14,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                          ),
                          child: Text(
                            widget.actionLabel,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 180),
                  crossFadeState: _isExpanded
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
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(14, 12, 14, 14),
                          child: SizedBox(height: 60),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

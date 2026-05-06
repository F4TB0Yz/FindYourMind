import 'dart:async';

import 'package:find_your_mind/config/theme/app_colors.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/one_time_habit_item_card/card_header.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/one_time_habit_item_card/expanded_section.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class TimedHabitItemCard extends StatefulWidget {
  const TimedHabitItemCard({
    required this.habit,
    required this.icon,
    required this.title,
    required this.description,
    required this.targetSeconds,
    required this.elapsedSeconds,
    required this.isExpanded,
    required this.onExpandTap,
    required this.onTimerTick,
    this.cardColor,
    super.key,
  });

  final HabitEntity habit;
  final String icon;
  final String title;
  final String description;
  final int targetSeconds;
  final int elapsedSeconds;
  final bool isExpanded;
  final VoidCallback onExpandTap;
  final ValueChanged<int> onTimerTick;
  final Color? cardColor;

  @override
  State<TimedHabitItemCard> createState() => _TimedHabitItemCardState();
}

class _TimedHabitItemCardState extends State<TimedHabitItemCard>
    with WidgetsBindingObserver {
  Timer? _timer;
  late int _elapsedSeconds;
  bool _isRunning = false;
  static const String _defaultEmoji = '⏱️';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _elapsedSeconds = widget.elapsedSeconds;
  }

  @override
  void didUpdateWidget(covariant TimedHabitItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isRunning && oldWidget.elapsedSeconds != widget.elapsedSeconds) {
      _elapsedSeconds = widget.elapsedSeconds;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _pauseAndCommit();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isRunning) {
      _pauseAndCommit();
      return;
    }

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _elapsedSeconds = (_elapsedSeconds + 1).clamp(0, widget.targetSeconds);
      });

      if (_elapsedSeconds >= widget.targetSeconds) {
        _pauseAndCommit();
      }
    });
  }

  void _pauseAndCommit() {
    _timer?.cancel();
    _timer = null;
    if (_isRunning && mounted) {
      setState(() {
        _isRunning = false;
      });
    } else {
      _isRunning = false;
    }
    widget.onTimerTick(_elapsedSeconds);
  }

  String _formatSeconds(int seconds) {
    final minutes = seconds ~/ 60;
    final remaining = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedCardColor =
        widget.cardColor ?? AppColors.oneTimeHabitCardColor(context);
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
    final progress = widget.targetSeconds == 0
        ? 0.0
        : (_elapsedSeconds / widget.targetSeconds).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onExpandTap,
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
                    resolvedEmoji: widget.icon.isNotEmpty ? widget.icon : _defaultEmoji,
                    title: widget.title,
                    description: widget.description,
                    streakDays: widget.habit.streak,
                    isExpanded: widget.isExpanded,
                    emojiBoxColor: emojiBoxColor,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: expandedSectionFillColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (Widget child,
                                    Animation<double> animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                                child: Text(
                                  _formatSeconds(_elapsedSeconds),
                                  key: ValueKey<int>(_elapsedSeconds),
                                  style: Theme.of(context)
                                      .textTheme
                                      .displaySmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: _elapsedSeconds >=
                                                widget.targetSeconds
                                            ? Theme.of(context).colorScheme.tertiary
                                            : Theme.of(context).colorScheme.primary,
                                        fontFeatures: [
                                          const FontFeature.tabularFigures()
                                        ],
                                      ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _elapsedSeconds >= widget.targetSeconds
                                          ? Theme.of(context).colorScheme.tertiary
                                          : Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Meta: ${_formatSeconds(widget.targetSeconds)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 62,
                              height: 62,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 5,
                                backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                color: _elapsedSeconds >= widget.targetSeconds
                                    ? Theme.of(context).colorScheme.tertiary
                                    : Theme.of(context).colorScheme.primary,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                            _TimerControlButton(
                              isRunning: _isRunning,
                              isCompleted: _elapsedSeconds >= widget.targetSeconds,
                              onTap: _toggleTimer,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ExpandedSection(
              isExpanded: widget.isExpanded,
              habit: widget.habit,
              cardFillColor: cardFillColor,
              expandedSectionFillColor: expandedSectionFillColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerControlButton extends StatefulWidget {
  final bool isRunning;
  final bool isCompleted;
  final VoidCallback onTap;

  const _TimerControlButton({
    required this.isRunning,
    required this.isCompleted,
    required this.onTap,
  });

  @override
  State<_TimerControlButton> createState() => _TimerControlButtonState();
}

class _TimerControlButtonState extends State<_TimerControlButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (widget.isCompleted) {
      return Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: cs.tertiary.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedTick01,
            size: 24,
            color: cs.tertiary,
          ),
        ),
      );
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.9),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: widget.isRunning
                ? cs.primary.withValues(alpha: 0.1)
                : cs.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: HugeIcon(
              icon: widget.isRunning
                  ? HugeIcons.strokeRoundedPause
                  : HugeIcons.strokeRoundedPlay,
              size: 24,
              color: widget.isRunning ? cs.primary : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

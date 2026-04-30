import 'dart:async';

import 'package:find_your_mind/config/theme/app_colors.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/one_time_habit_item_card/card_header.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class TimedHabitItemCard extends StatefulWidget {
  const TimedHabitItemCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.streakDays,
    required this.targetSeconds,
    required this.elapsedSeconds,
    required this.isExpanded,
    required this.onExpandTap,
    required this.onTimerTick,
    this.cardColor,
    super.key,
  });

  final String icon;
  final String title;
  final String description;
  final int streakDays;
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
                    streakDays: widget.streakDays,
                    isExpanded: widget.isExpanded,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatSeconds(_elapsedSeconds),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Text(
                              '/ ${_formatSeconds(widget.targetSeconds)}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: Colors.black.withValues(alpha: 0.08),
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonalIcon(
                            onPressed: _toggleTimer,
                            icon: HugeIcon(
                              icon: _isRunning
                                  ? HugeIcons.strokeRoundedPause
                                  : HugeIcons.strokeRoundedPlay,
                              size: 18,
                            ),
                            label: Text(_isRunning ? 'Pausar' : 'Iniciar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 180),
              crossFadeState: widget.isExpanded
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
                      'Hoy: ${_formatSeconds(_elapsedSeconds)} de ${_formatSeconds(widget.targetSeconds)}',
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

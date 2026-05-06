import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TrackingTypeOptionCard extends StatefulWidget {
  final String emoji;
  final String title;
  final HabitTrackingType trackingType;

  const TrackingTypeOptionCard({
    super.key,
    required this.emoji,
    required this.title,
    required this.trackingType,
  });

  @override
  State<TrackingTypeOptionCard> createState() => _TrackingTypeOptionCardState();
}

class _TrackingTypeOptionCardState extends State<TrackingTypeOptionCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = context.select<NewHabitProvider, bool>(
      (p) => p.trackingType == widget.trackingType,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        context.read<NewHabitProvider>().setTrackingType(widget.trackingType);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        scale: _isPressed ? 0.96 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF15B0B8).withValues(alpha: 0.28)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.5),
              width: isSelected ? 1.5 : 1.0,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                scale: isSelected ? 1.25 : 1.0,
                child: Text(widget.emoji, style: const TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                ),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/tracking_type_option_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SheetTrackingTypeRow extends StatelessWidget {
  const SheetTrackingTypeRow({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIPO',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: colorScheme.outline,
          ),
        ),
        const SizedBox(height: 8),
        const Row(
          children: [
            Expanded(
              child: TrackingTypeOptionCard(
                emoji: '🎯',
                title: 'Una vez',
                trackingType: HabitTrackingType.single,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TrackingTypeOptionCard(
                emoji: '🔢',
                title: 'Contador',
                trackingType: HabitTrackingType.counter,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TrackingTypeOptionCard(
                emoji: '⏱️',
                title: 'Por tiempo',
                trackingType: HabitTrackingType.timed,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

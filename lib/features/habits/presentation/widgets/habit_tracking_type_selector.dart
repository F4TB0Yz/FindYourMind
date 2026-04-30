import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/card_option_custom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HabitTrackingTypeSelector extends StatelessWidget {
  const HabitTrackingTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tracking',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B949E),
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _TrackingTypeButton(
                label: 'Una vez',
                type: HabitTrackingType.single,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _TrackingTypeButton(
                label: 'Tiempo',
                type: HabitTrackingType.timed,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _TrackingTypeButton(
                label: 'Conteo',
                type: HabitTrackingType.counter,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TrackingTypeButton extends StatelessWidget {
  final String label;
  final HabitTrackingType type;

  const _TrackingTypeButton({required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewHabitProvider>(context);

    return CardOptionCustom(
      title: label,
      isSelected: provider.trackingType == type,
      canBeSelected: true,
      onTap: () => provider.setTrackingType(type),
    );
  }
}

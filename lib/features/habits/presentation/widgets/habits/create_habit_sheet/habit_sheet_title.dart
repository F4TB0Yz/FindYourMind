import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HabitSheetTitle extends StatelessWidget {
  const HabitSheetTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      'Nuevo hábito',
      style: GoogleFonts.fraunces(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
    );
  }
}

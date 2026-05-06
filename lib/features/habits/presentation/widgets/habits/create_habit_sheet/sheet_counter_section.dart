import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/habit_sheet_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class SheetCounterSection extends StatelessWidget {
  const SheetCounterSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final targetValue = context.select<NewHabitProvider, int>(
      (p) => p.targetValue,
    );
    final provider = context.read<NewHabitProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "META DIARIA",
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: cs.outline,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _CounterButton(
              icon: HugeIcons.strokeRoundedMinusSign,
              onTap: () => provider.setTargetValue(targetValue - 1),
            ),
            const SizedBox(width: 24),
            Text(
              targetValue.toString(),
              style: GoogleFonts.fraunces(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(width: 24),
            _CounterButton(
              icon: HugeIcons.strokeRoundedAdd01,
              onTap: () => provider.setTargetValue(targetValue + 1),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: HabitSheetTextField(
                controller: provider.unitController,
                hintText: 'unidad (vasos, páginas..)',
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _CounterButton extends StatelessWidget {
  final List<List<dynamic>> icon;
  final VoidCallback onTap;

  const _CounterButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark
                ? cs.outline.withValues(alpha: 0.5)
                : const Color(0xFF334155).withValues(alpha: 0.7),
            width: 1.2,
          ),
        ),
        child: HugeIcon(icon: icon, size: 20, color: cs.onSurface),
      ),
    );
  }
}

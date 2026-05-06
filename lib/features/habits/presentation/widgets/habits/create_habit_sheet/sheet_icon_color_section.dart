import 'package:find_your_mind/config/theme/app_colors.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_color_grid.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_icon_grid.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_tab_toggle.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SheetIconColorSection extends StatefulWidget {
  const SheetIconColorSection({super.key});

  @override
  State<SheetIconColorSection> createState() => _SheetIconColorSectionState();
}

class _SheetIconColorSectionState extends State<SheetIconColorSection> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedIcon = context.select<NewHabitProvider, String>(
      (p) => p.selectedIcon,
    );
    final selectedColorStr = context.select<NewHabitProvider, String>(
      (p) => p.selectedColor,
    );
    final title = context.select<NewHabitProvider, String>(
      (p) => p.titleController.text,
    );

    final color = selectedColorStr == 'random'
        ? AppColors.habitCardPalette[0]
        : AppColors.habitCardColorFromHex(selectedColorStr);

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(selectedIcon, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "VISTA PREVIA",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    title.isEmpty ? "Título del hábito" : title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 4),

            Expanded(
              flex: 1,
              child: SheetTabToggle(
                labels: const ['EMOJI', 'COLOR'],
                selectedIndex: _tabIndex,
                onChanged: (index) => setState(() => _tabIndex = index),
              ),
            ),
          ],
        ),  
        const SizedBox(height: 20),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          child: _tabIndex == 0
              ? const SheetIconGrid(key: ValueKey('icon_grid'))
              : const SheetColorGrid(key: ValueKey('color_grid')),
        ),
      ],
    );
  }
}

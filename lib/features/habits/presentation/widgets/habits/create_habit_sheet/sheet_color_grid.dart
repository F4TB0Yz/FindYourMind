import 'package:find_your_mind/config/theme/app_colors.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SheetColorGrid extends StatelessWidget {
  const SheetColorGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedColor = context.select<NewHabitProvider, String>(
      (p) => p.selectedColor,
    );
    final provider = context.read<NewHabitProvider>();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: AppColors.habitCardPalette.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          final isSelected = selectedColor == 'random';
          return _ColorOption(
            isSelected: isSelected,
            onTap: () => provider.setSelectedColor('random'),
            child: Icon(
              Icons.shuffle_rounded,
              size: 24,
              color: isSelected ? cs.primary : cs.onSurfaceVariant,
            ),
          );
        }

        final color = AppColors.habitCardPalette[index - 1];
        final hex =
            '0x${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
        final isSelected = selectedColor == hex;

        return _ColorOption(
          color: color,
          isSelected: isSelected,
          onTap: () => provider.setSelectedColor(hex),
          child: isSelected
              ? Icon(
                  Icons.check_rounded,
                  color: Colors.black.withValues(alpha: 0.5),
                )
              : null,
        );
      },
    );
  }
}

class _ColorOption extends StatelessWidget {
  final Color? color;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? child;

  const _ColorOption({
    this.color,
    required this.isSelected,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: color ?? cs.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outlineVariant,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: cs.primary.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Center(child: child),
      ),
    );
  }
}

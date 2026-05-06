import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SheetIconGrid extends StatelessWidget {
  const SheetIconGrid({super.key});

  static const _emojis = [
    '💧', '🧘', '📖', '🚶', '💊', '🏋️', '🥗', '🛏️',
    '✍️', '🎸', '☕', '🧹', '🏃', '🫁', '🥤', '🎯',
    '🌱', '🍎', '🎨', '🪴', '🐾', '🌞', '🎵', '🧠'
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedIcon = context.select<NewHabitProvider, String>(
      (p) => p.selectedIcon,
    );
    final provider = context.read<NewHabitProvider>();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: _emojis.length,
      itemBuilder: (context, index) {
        final emoji = _emojis[index];
        final isSelected = selectedIcon == emoji;

        return GestureDetector(
          onTap: () => provider.setSelectedIcon(emoji),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? cs.primary.withValues(alpha: 0.15) : cs.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? cs.primary : cs.outlineVariant,
                width: isSelected ? 2 : 1.2,
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
        );
      },
    );
  }
}

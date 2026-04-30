import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/card_option_custom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TypeHabitSelector extends StatelessWidget {
  const TypeHabitSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categoría',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF8B949E),
          ),
        ),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _TypeHabitButton(label: 'Salud', type: HabitCategory.health)),
            SizedBox(width: 8),
            Expanded(child: _TypeHabitButton(label: 'Personal', type: HabitCategory.personal)),
            SizedBox(width: 8),
            Expanded(child: _TypeHabitButton(label: 'Productividad', type: HabitCategory.productivity)),
          ],
        ),
      ],
    );
  }
}

class _TypeHabitButton extends StatelessWidget {
  final String label;
  final HabitCategory type;

  const _TypeHabitButton({required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewHabitProvider>(context);
    final isSelected = provider.selectedCategory == type;
    final hasSelection = provider.hasSelectedCategory;

    return CardOptionCustom(
      title: label,
      isSelected: isSelected,
      canBeSelected: !hasSelection || isSelected,
      onTap: () {
        if (isSelected) {
          provider.clearCategory();
        } else {
          provider.setCategory(type);
        }
      },
    );
  }
}

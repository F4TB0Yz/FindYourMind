import 'package:find_your_mind/features/habits/domain/entities/type_habit.dart';
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
          'Tipo de Habito',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white38
          ),
        ),

        SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _TypeHabitButton(
              label: 'Salud', 
              type: TypeHabit.health, 
            ),
            _TypeHabitButton(
              label: 'Personal', 
              type: TypeHabit.personal, 
            ),
            _TypeHabitButton(
              label: 'Productividad', 
              type: TypeHabit.productivity, 
            )
          ],
        ),
      ],
    );
  }
}

class _TypeHabitButton extends StatelessWidget {
  final String label;
  final TypeHabit type;

  const _TypeHabitButton({
    required this.label, 
    required this.type, 
  });

  @override
  Widget build(BuildContext context) {
    final NewHabitProvider newHabitProvider = Provider.of<NewHabitProvider>(context);

    void onTapButton(NewHabitProvider provider, TypeHabit type) {
      if (!provider.isTypeSelected(type) && provider.isSelectedTypeHabit) {
        return;
      }

      if (provider.isTypeSelected(type) && newHabitProvider.typeHabitSelected == type) {
        provider.clearTypeHabit();
        return;
      } 

      provider.setTypeHabit(type);
    }

    return CardOptionCustom(
      title: label,
      canBeSelected: !newHabitProvider.isSelectedTypeHabit,
      onTap: () => onTapButton(newHabitProvider, type),
    );
  }
}
import 'package:find_your_mind/features/habits/domain/entities/type_habit.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/card_option_custom.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Selector de tipo de hábito: Salud, Personal y Productividad.
///
/// Solo permite seleccionar un tipo a la vez. El estado seleccionado
/// se comunica visualmente mediante borde y color del [CardOptionCustom].
class TypeHabitSelector extends StatelessWidget {
  const TypeHabitSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Hábito',
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
            Expanded(child: _TypeHabitButton(label: 'Salud', type: TypeHabit.health)),
            SizedBox(width: 8),
            Expanded(child: _TypeHabitButton(label: 'Personal', type: TypeHabit.personal)),
            SizedBox(width: 8),
            Expanded(child: _TypeHabitButton(label: 'Productividad', type: TypeHabit.productivity)),
          ],
        ),
      ],
    );
  }
}

/// Botón de tipo de hábito individual con estado seleccionado/disponible/deshabilitado.
class _TypeHabitButton extends StatelessWidget {
  final String label;
  final TypeHabit type;

  const _TypeHabitButton({required this.label, required this.type});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewHabitProvider>(context);
    final bool isSelected = provider.typeHabitSelected == type;
    final bool hasSelection = provider.isSelectedTypeHabit;

    return CardOptionCustom(
      title: label,
      isSelected: isSelected,
      canBeSelected: !hasSelection || isSelected,
      onTap: () {
        if (isSelected) {
          provider.clearTypeHabit();
        } else {
          provider.setTypeHabit(type);
        }
      },
    );
  }
}
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_tab_toggle.dart';
import 'package:flutter/material.dart';

class NameDescriptionToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const _labels = ['NOMBRE', 'DESCRIPCIÓN'];

  const NameDescriptionToggle({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: IntrinsicWidth(
        child: SheetTabToggle(
          labels: _labels,
          selectedIndex: selectedIndex,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/habit_sheet_text_field.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/habit_sheet_title.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/name_description_toggle.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_tracking_type_row.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateHabitSheet extends StatefulWidget {
  const CreateHabitSheet({super.key});

  @override
  State<CreateHabitSheet> createState() => _CreateHabitSheetState();
}

class _CreateHabitSheetState extends State<CreateHabitSheet> {
  int _selectedTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NewHabitProvider>();

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const HabitSheetTitle(),
            const SizedBox(height: 24),
            NameDescriptionToggle(
              selectedIndex: _selectedTabIndex,
              onChanged: (index) => setState(() => _selectedTabIndex = index),
            ),
            const SizedBox(height: 16),
            _selectedTabIndex == 0
                ? HabitSheetTextField(
                    key: const ValueKey('name_input'),
                    controller: provider.titleController,
                    hintText: 'ej. Beber agua',
                  )
                : HabitSheetTextField(
                    key: const ValueKey('desc_input'),
                    controller: provider.descriptionController,
                    hintText: 'Agrega una descripción...',
                  ),
            const SizedBox(height: 24),
            const SheetTrackingTypeRow(),
          ],
        ),
      ),
    );
  }
}

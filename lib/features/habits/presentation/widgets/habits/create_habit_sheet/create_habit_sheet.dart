import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/providers/new_habit_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/habit_sheet_text_field.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/habit_sheet_title.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/name_description_toggle.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_footer_actions.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_icon_color_section.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_tracking_config_section.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/sheet_tracking_type_row.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateHabitSheet extends StatefulWidget {
  const CreateHabitSheet({super.key});

  @override
  State<CreateHabitSheet> createState() => _CreateHabitSheetState();
}

class _CreateHabitSheetState extends State<CreateHabitSheet> {
  int _selectedTabIndex = 0;
  String? _titleError;
  late final TextEditingController _titleController;

  @override
  void initState() {
    super.initState();
    _titleController = context.read<NewHabitProvider>().titleController;
    // Listen to title changes to rebuild and update preview
    _titleController.addListener(_onTitleChanged);
  }

  @override
  void dispose() {
    _titleController.removeListener(_onTitleChanged);
    super.dispose();
  }

  void _onTitleChanged() {
    if (_titleError != null) {
      setState(() => _titleError = null);
    }
    if (mounted) setState(() {});
  }

  Future<void> _onSaveHabit() async {
    final newHabitProvider = context.read<NewHabitProvider>();
    final habitsProvider = context.read<HabitsProvider>();

    if (newHabitProvider.titleController.text.trim().isEmpty) {
      setState(() => _titleError = 'El título es obligatorio.');
      return;
    }

    final userId = await habitsProvider.getUserId();
    if (!mounted) return;

    if (userId == null) {
      CustomToast.showToast(
        context: context,
        message: 'Error: No se pudo identificar al usuario',
      );
      return;
    }

    final habit = HabitEntity(
      id: '',
      userId: userId,
      title: newHabitProvider.titleController.text,
      description: newHabitProvider.descriptionController.text,
      icon: newHabitProvider.selectedIcon,
      color: newHabitProvider.selectedColor,
      unit: newHabitProvider.unitController.text.isNotEmpty
          ? newHabitProvider.unitController.text
          : null,
      category: newHabitProvider.selectedCategory,
      trackingType: newHabitProvider.trackingType,
      targetValue: newHabitProvider.targetValue,
      initialDate: DateTime.now().toIso8601String(),
      logs: const [],
    );

    Navigator.of(context).pop();
    CustomToast.showToast(context: context, message: 'Hábito creado');
    newHabitProvider.clear();
    habitsProvider.createHabit(habit);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NewHabitProvider>();

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: HabitSheetTitle(),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        NameDescriptionToggle(
                          selectedIndex: _selectedTabIndex,
                          onChanged: (index) =>
                              setState(() => _selectedTabIndex = index),
                        ),
                        const SizedBox(height: 16),
                        _selectedTabIndex == 0
                            ? HabitSheetTextField(
                                key: const ValueKey('name_input'),
                                controller: provider.titleController,
                                hintText: 'ej. Beber agua',
                                errorText: _titleError,
                              )
                            : HabitSheetTextField(
                                key: const ValueKey('desc_input'),
                                controller: provider.descriptionController,
                                hintText: 'Agrega una descripción...',
                              ),
                        const SizedBox(height: 24),
                        const SheetTrackingTypeRow(),
                        const SizedBox(height: 24),
                        const SheetTrackingConfigSection(),
                        const SheetIconColorSection(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  SheetFooterActions(
                    onCancel: () => Navigator.of(context).pop(),
                    onSave: _onSaveHabit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

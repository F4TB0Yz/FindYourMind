import 'package:find_your_mind/features/habits/presentation/screens/habits_screen.dart';
import 'package:find_your_mind/features/notes/presentation/screens/notes_screen.dart';
import 'package:find_your_mind/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:find_your_mind/shared/presentation/widgets/bottom_nav_bar/custom_item_bar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(15),
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xff2A2A2A)
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomItemBar(
              icon: LucideIcons.penTool,
              label: 'Notas',
              screen: NotesScreen(),
            ),
            CustomItemBar(
              icon: LucideIcons.checkSquare,
              label: 'Tareas',
              screen: TasksScreen(),
            ),
            CustomItemBar(
              icon: LucideIcons.clock,
              label: 'Habitos',
              screen: HabitsScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
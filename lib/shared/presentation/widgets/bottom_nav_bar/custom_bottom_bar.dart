import 'package:find_your_mind/features/habits/presentation/screens/habits_screen.dart';
import 'package:find_your_mind/features/notes/presentation/screens/notes_screen.dart';
import 'package:find_your_mind/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:find_your_mind/shared/domain/entities/screen_type.dart';
import 'package:find_your_mind/shared/presentation/widgets/bottom_nav_bar/custom_item_bar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Capa: Presentation → Widgets (Shared)
/// Barra de navegación inferior fija. Sin márgenes externos, sin bordes redondeados.
/// Separada del contenido por un borde superior sutil.
class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF0d1117),
        border: Border(
          top: BorderSide(color: Color(0xFF30363d), width: 1),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CustomItemBar(
            icon: LucideIcons.penTool,
            screen: NotesScreen(),
            screenType: ScreenType.notes,
          ),
          CustomItemBar(
            icon: LucideIcons.checkSquare,
            screen: TasksScreen(),
            screenType: ScreenType.tasks,
          ),
          CustomItemBar(
            icon: LucideIcons.clock,
            screen: HabitsScreen(),
            screenType: ScreenType.habits,
          ),
        ],
      ),
    );
  }
}
import 'package:find_your_mind/features/habits/presentation/screens/habits_screen.dart';
import 'package:find_your_mind/features/notes/presentation/screens/notes_screen.dart';
import 'package:find_your_mind/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:find_your_mind/features/profile/presentation/screens/profile_screen.dart';
import 'package:find_your_mind/features/auth/presentation/providers/auth_service_locator.dart';
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
    return BottomAppBar(
      height: 65,
      padding: EdgeInsets.zero,
      color: const Color(0xFF0d1117),
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const CustomItemBar(
            icon: LucideIcons.penTool,
            screen: NotesScreen(),
            screenType: ScreenType.notes,
          ),
          const CustomItemBar(
            icon: LucideIcons.checkSquare,
            screen: TasksScreen(),
            screenType: ScreenType.tasks,
          ),
          const SizedBox(width: 48), // Espacio para el FAB
          const CustomItemBar(
            icon: LucideIcons.clock,
            screen: HabitsScreen(),
            screenType: ScreenType.habits,
          ),
          CustomItemBar(
            icon: LucideIcons.user,
            screen: ProfileScreen(
              getCurrentUserUseCase: AuthServiceLocator().getCurrentUserUseCase,
              signOutUseCase: AuthServiceLocator().signOutUseCase,
            ),
            screenType: ScreenType.profile,
          ),
        ],
      ),
    );
  }
}
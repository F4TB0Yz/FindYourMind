import 'package:find_your_mind/shared/presentation/widgets/bottom_nav_bar/custom_item_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Barra de navegación inferior fija.
/// Desacoplada de ScreensProvider — usa [StatefulNavigationShell] de GoRouter.
class CustomBottomBar extends StatelessWidget {
  final StatefulNavigationShell shell;

  const CustomBottomBar({super.key, required this.shell});

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
          CustomItemBar(
            icon: LucideIcons.penTool,
            index: 2, // notes
            currentIndex: shell.currentIndex,
            onTap: () => shell.goBranch(2),
          ),
          CustomItemBar(
            icon: LucideIcons.checkSquare,
            index: 1, // tasks
            currentIndex: shell.currentIndex,
            onTap: () => shell.goBranch(1),
          ),
          const SizedBox(width: 48), // espacio para el FAB
          CustomItemBar(
            icon: LucideIcons.clock,
            index: 0, // habits
            currentIndex: shell.currentIndex,
            onTap: () => shell.goBranch(0),
          ),
          CustomItemBar(
            icon: LucideIcons.user,
            index: 3, // profile
            currentIndex: shell.currentIndex,
            onTap: () => shell.goBranch(3),
          ),
        ],
      ),
    );
  }
}
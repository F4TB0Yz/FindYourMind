import 'package:find_your_mind/shared/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:find_your_mind/shared/presentation/widgets/bottom_nav_bar/custom_bottom_bar.dart';
import 'package:find_your_mind/shared/presentation/widgets/fab/habits_fab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell persistente: AppBar + BottomBar + FAB condicional.
/// Se renderiza UNA sola vez; solo el [shell] (contenido interior) cambia.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    final bool isHabitsTab = shell.currentIndex == 0;

    return Scaffold(
      appBar: const CustomAppBar(),
      body: shell,
      bottomNavigationBar: CustomBottomBar(shell: shell),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isHabitsTab ? const HabitsFab() : null,
    );
  }
}

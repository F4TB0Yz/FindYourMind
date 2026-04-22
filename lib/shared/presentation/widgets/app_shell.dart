import 'package:find_your_mind/shared/presentation/widgets/app_bar/app_bar.dart';
import 'package:find_your_mind/shared/presentation/widgets/bottom_nav_bar/custom_bottom_bar.dart';
import 'package:find_your_mind/shared/presentation/widgets/fab/habits_fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

/// Shell persistente: AppBar + BottomBar + FAB condicional.
/// El MainAppBar es global y se muestra en todas las pantallas del shell.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    final bool isHabitsTab = shell.currentIndex == 0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: surfaceColor,
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
        statusBarColor: surfaceColor,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        appBar: MainAppBar(isProfileActive: shell.currentIndex == 3),
        body: shell,
        bottomNavigationBar: CustomBottomBar(shell: shell),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: isHabitsTab ? const HabitsFab() : null,
      ),
    );
  }
}

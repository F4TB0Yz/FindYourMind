import 'package:find_your_mind/shared/presentation/widgets/app_bar/app_bar.dart';
import 'package:find_your_mind/shared/presentation/widgets/bottom_nav_bar/custom_bottom_bar.dart';
import 'package:find_your_mind/shared/presentation/widgets/fab/main_fab.dart';
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
        appBar: MainAppBar(
          isProfileActive: shell.currentIndex == 3,
          currentIndex: shell.currentIndex,
        ),
        body: shell,
        bottomNavigationBar: CustomBottomBar(shell: shell),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: MainFab(
          onPressed: () {
            switch (shell.currentIndex) {
              case 0: // Hábitos
                context.push('/habits/new');
                break;
              case 1: // Tareas
                context.push('/tasks/new');
                break;
              case 2: // Notas
                context.push('/notes/new');
                break;
              default:
                break;
            }
          },
        ),
      ),
    );
  }
}

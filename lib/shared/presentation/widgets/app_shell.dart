import 'package:find_your_mind/shared/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:find_your_mind/shared/presentation/widgets/bottom_nav_bar/custom_bottom_bar.dart';
import 'package:find_your_mind/shared/presentation/widgets/fab/habits_fab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shell persistente: AppBar + BottomBar + FAB condicional.
/// Determina el título dinámicamente basado en la ruta activa.
class AppShell extends StatelessWidget {
  final StatefulNavigationShell shell;

  const AppShell({super.key, required this.shell});

  @override
  Widget build(BuildContext context) {
    final bool isHabitsTab = shell.currentIndex == 0;
    
    // Obtener el nombre de la ruta actual para el título del AppBar.
    // Esto evita hardcodear títulos en cada pantalla individual.
    final String currentTitle = _getRouteTitle(context);

    return Scaffold(
      appBar: CustomAppBar(title: currentTitle),
      body: shell,
      bottomNavigationBar: CustomBottomBar(shell: shell),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: isHabitsTab ? const HabitsFab() : null,
    );
  }

  String _getRouteTitle(BuildContext context) {
    final state = GoRouterState.of(context);
    // Usamos el 'name' definido en el AppRouter.
    return state.name ?? state.matchedLocation.split('/').last;
  }
}

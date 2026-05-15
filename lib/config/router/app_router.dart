import 'package:find_your_mind/features/auth/presentation/providers/auth_service_locator.dart';
import 'package:find_your_mind/features/auth/presentation/screens/login_screen.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habit_detail_screen/habit_detail_screen.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habits_redesign_screen.dart';
import 'package:find_your_mind/features/habits/presentation/screens/new_habit_screen.dart';
import 'package:find_your_mind/features/notes/presentation/screens/notes_screen.dart';
import 'package:find_your_mind/features/profile/presentation/screens/profile_screen.dart';
import 'package:find_your_mind/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:find_your_mind/shared/presentation/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppRouter {
  AppRouter._();

  static final _authNotifier = _AuthChangeNotifier();
  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/habits',
    refreshListenable: _authNotifier,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggingIn = state.matchedLocation == '/login';

      if (session == null && !isLoggingIn) return '/login';
      if (session != null && isLoggingIn) return '/habits';
      return null;
    },
    routes: [
      // ─── Login (fuera del shell) ──────────────────────────────────────────
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const NoTransitionPage(
          child: _LoginWrapper(),
        ),
      ),

      // ─── Shell: layout persistente (bottom bar + frame) ──────────────────
      StatefulShellRoute(
        navigatorContainerBuilder:
            (context, navigationShell, children) => _LazyBranchContainer(
              navigationShell: navigationShell,
              children: children,
            ),
        builder: (context, state, navigationShell) =>
            AppShell(shell: navigationShell),
        branches: [
          // Branch 0: Hábitos
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'habitos',
                path: '/habits',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HabitsRedesignScreen(),
                ),
                routes: [
                  // /habits/new — push desde FAB, back nativo funciona
                  GoRoute(
                    name: 'nuevo_habito',
                    path: 'new',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const NewHabitScreen(),
                  ),
                  // /habits/:habitId — push desde SlidableItem con extra: HabitEntity
                  GoRoute(
                    name: 'detalle_habito',
                    path: ':habitId',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final habit = state.extra as HabitEntity;
                      return HabitDetailScreen(habit: habit);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Tareas
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'tareas',
                path: '/tasks',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TasksScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Nueva Tarea (Próximamente)')),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Branch 2: Notas
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'notas',
                path: '/notes',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: NotesScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'new',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Nueva Nota (Próximamente)')),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Perfil
          StatefulShellBranch(
            routes: [
              GoRoute(
                name: 'perfil',
                path: '/profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProfileScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Renderiza solo ramas ya visitadas para reducir costo de build inicial.
class _LazyBranchContainer extends StatefulWidget {
  const _LazyBranchContainer({
    required this.navigationShell,
    required this.children,
  });

  final StatefulNavigationShell navigationShell;
  final List<Widget> children;

  @override
  State<_LazyBranchContainer> createState() => _LazyBranchContainerState();
}

class _LazyBranchContainerState extends State<_LazyBranchContainer> {
  late final Set<int> _loadedBranches;

  @override
  void initState() {
    super.initState();
    _loadedBranches = <int>{widget.navigationShell.currentIndex};
  }

  @override
  void didUpdateWidget(covariant _LazyBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadedBranches.add(widget.navigationShell.currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;

    return Stack(
      children: List<Widget>.generate(widget.children.length, (index) {
        if (!_loadedBranches.contains(index)) {
          return const SizedBox.shrink();
        }

        return Offstage(
          offstage: currentIndex != index,
          child: TickerMode(
            enabled: currentIndex == index,
            child: widget.children[index],
          ),
        );
      }),
    );
  }
}

/// ChangeNotifier que escucha onAuthStateChange de Supabase
/// y notifica al GoRouter para re-evaluar el redirect en runtime.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier() {
    Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }
}

/// Pasa use-cases desde AuthServiceLocator al LoginScreen.
class _LoginWrapper extends StatelessWidget {
  const _LoginWrapper();

  @override
  Widget build(BuildContext context) {
    return LoginScreen(
      signInUseCase: AuthServiceLocator().signInWithEmailUseCase,
      signUpUseCase: AuthServiceLocator().signUpWithEmailUseCase,
      signInWithGoogleUseCase: AuthServiceLocator().signInWithGoogleUseCase,
    );
  }
}

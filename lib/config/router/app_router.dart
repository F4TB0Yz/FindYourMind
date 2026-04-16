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

  static final GoRouter router = GoRouter(
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
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(shell: navigationShell),
        branches: [
          // Branch 0: Hábitos
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/habits',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HabitsRedesignScreen(),
                ),
                routes: [
                  // /habits/new — push desde FAB, back nativo funciona
                  GoRoute(
                    path: 'new',
                    builder: (context, state) => const NewHabitScreen(),
                  ),
                  // /habits/:habitId — push desde SlidableItem con extra: HabitEntity
                  GoRoute(
                    path: ':habitId',
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
                path: '/tasks',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TasksScreen(),
                ),
              ),
            ],
          ),

          // Branch 2: Notas
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/notes',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: NotesScreen(),
                ),
              ),
            ],
          ),

          // Branch 3: Perfil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                pageBuilder: (context, state) => NoTransitionPage(
                  child: ProfileScreen(
                    getCurrentUserUseCase:
                        AuthServiceLocator().getCurrentUserUseCase,
                    signOutUseCase: AuthServiceLocator().signOutUseCase,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
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

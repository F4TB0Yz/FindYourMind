import 'package:find_your_mind/core/services/auth_service.dart';
import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/features/auth/presentation/screens/login_screen.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/animated_screen_transition.dart';
import 'package:find_your_mind/features/habits/presentation/screens/new_habit_screen.dart';
import 'package:find_your_mind/shared/presentation/widgets/bottom_nav_bar/custom_bottom_bar.dart';
import 'package:find_your_mind/shared/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:find_your_mind/shared/domain/entities/screen_type.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  final AuthService authService;
  final SignInWithEmailUseCase signInUseCase;
  final SignUpWithEmailUseCase signUpUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignOutUseCase signOutUseCase;

  const AuthScreen({
    super.key,
    required this.authService,
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signInWithGoogleUseCase,
    required this.signOutUseCase,
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  /// Evita recargar hábitos si el usuario no cambió entre redraws del stream.
  String? _lastLoadedUserId;

  /// Previene llamadas concurrentes a loadHabits.
  bool _isLoadingHabits = false;

  void _loadHabitsForUser(String userId) {
    if (_lastLoadedUserId == userId || _isLoadingHabits) return;

    _isLoadingHabits = true;
    _lastLoadedUserId = userId;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);
      await habitsProvider.loadHabits();
      _isLoadingHabits = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screensProvider = Provider.of<ScreensProvider>(context);

    return StreamBuilder(
      stream: widget.authService.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0d1117),
            body: SizedBox.shrink(),
          );
        }

        final Session? session =
            snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          _loadHabitsForUser(session.user.id);

          return Scaffold(
            appBar: const CustomAppBar(),
            body: AnimatedScreenTransition(
              child: screensProvider.currentPageWidget,
            ),
            bottomNavigationBar: const CustomBottomBar(),
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: screensProvider.currentScreenType == ScreenType.habits
                ? Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF6366F1),
                          Color(0xFF4F46E5),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.35),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: FloatingActionButton(
                      onPressed: () => screensProvider.setScreenWidget(
                        const NewHabitScreen(),
                        ScreenType.newHabit,
                      ),
                      elevation: 0,
                      backgroundColor: Colors.transparent,
                      shape: const CircleBorder(),
                      child: const Icon(Icons.add, color: Colors.white, size: 30),
                    ),
                  )
                : null,
          );
        }

        _lastLoadedUserId = null;
        _isLoadingHabits = false;

        return LoginScreen(
          signInUseCase: widget.signInUseCase,
          signUpUseCase: widget.signUpUseCase,
          signInWithGoogleUseCase: widget.signInWithGoogleUseCase,
        );
      },
    );
  }
}

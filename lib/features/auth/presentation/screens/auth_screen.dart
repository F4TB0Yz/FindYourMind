import 'package:find_your_mind/core/services/auth_service.dart';
import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/features/auth/presentation/screens/login_screen.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// AuthScreen ahora es solo un guard de sesión para mantener compatibilidad.
/// La lógica de redirección principal ocurre en AppRouter.redirect.
/// Este widget puede mantenerse para manejar la precarga de hábitos al autenticar.
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
  String? _lastLoadedUserId;
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
          // El router ya manejó la redirección a /habits — devuelve placeholder.
          return const Scaffold(backgroundColor: Color(0xFF0d1117));
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

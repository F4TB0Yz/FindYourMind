import 'package:find_your_mind/core/services/auth_service.dart';
import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/features/auth/presentation/screens/login_screen.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/animated_screen_transition.dart';
import 'package:find_your_mind/shared/presentation/widgets/bottom_nav_bar/custom_bottom_bar.dart';
import 'package:find_your_mind/shared/presentation/widgets/app_bar/custom_app_bar.dart';
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
  String? _lastLoadedUserId; // Rastrear el último usuario cargado
  bool _isLoadingHabits = false; // Prevenir llamadas concurrentes

  @override
  Widget build(BuildContext context) {
    final screensProvider = Provider.of<ScreensProvider>(context);

    return StreamBuilder(
      stream: widget.authService.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final Session? session = snapshot.hasData
            ? snapshot.data!.session
            : null;

        if (session != null) {
          final currentUserId = session.user.id;
          
          // Solo cargar hábitos si es un usuario diferente al último cargado Y no hay carga en progreso
          if (_lastLoadedUserId != currentUserId && !_isLoadingHabits) {
            print('🔐 [AUTH_SCREEN] Nuevo usuario detectado: $currentUserId');
            print('🔐 [AUTH_SCREEN] Último usuario cargado: $_lastLoadedUserId');
            
            // Marcar inmediatamente como cargando para prevenir llamadas concurrentes
            _isLoadingHabits = true;
            _lastLoadedUserId = currentUserId;
            
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);
              
              print('🔐 [AUTH_SCREEN] Llamando a loadHabits()...');
              // Cargar hábitos desde SQLite (la sincronización automática se encargará del resto)
              await habitsProvider.loadHabits();
              _isLoadingHabits = false;
              print('🔐 [AUTH_SCREEN] loadHabits() completado');
            });
          } else if (_lastLoadedUserId == currentUserId) {
            print('🔐 [AUTH_SCREEN] Mismo usuario, no se recargan hábitos');
          } else if (_isLoadingHabits) {
            print('🔐 [AUTH_SCREEN] Carga ya en progreso, ignorando...');
          }
          
          return Scaffold(
            appBar: CustomAppBar(signOutUseCase: widget.signOutUseCase),
            body: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: AnimatedScreenTransition(
                child: screensProvider.currentPageWidget,
              ),
            ),
            bottomNavigationBar: const CustomBottomBar(),
          );
        } else {
          // Usuario no autenticado - resetear el tracking
          _lastLoadedUserId = null;
          _isLoadingHabits = false;
          
          return LoginScreen(
            signInUseCase: widget.signInUseCase,
            signUpUseCase: widget.signUpUseCase,
            signInWithGoogleUseCase: widget.signInWithGoogleUseCase,
          );
        }
      },
    );
  }
}

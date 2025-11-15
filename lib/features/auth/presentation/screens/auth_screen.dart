import 'package:find_your_mind/core/services/auth_service.dart';
import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/features/auth/presentation/screens/login_screen.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/animated_screen_transition.dart';
import 'package:find_your_mind/shared/presentation/widgets/bottom_nav_bar/custom_bottom_bar.dart';
import 'package:find_your_mind/shared/presentation/widgets/app_bar/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatelessWidget {
  final AuthService authService;
  final SignInWithEmailUseCase signInUseCase;
  final SignUpWithEmailUseCase signUpUseCase;
  final SignOutUseCase signOutUseCase;

  const AuthScreen({
    super.key,
    required this.authService,
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signOutUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final screensProvider = Provider.of<ScreensProvider>(context);

    return StreamBuilder(
      stream: authService.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final Session? session = snapshot.hasData
            ? snapshot.data!.session
            : null;

        if (session != null) {
          return Scaffold(
            appBar: CustomAppBar(signOutUseCase: signOutUseCase),
            body: Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
              child: AnimatedScreenTransition(
                child: screensProvider.currentPageWidget,
              ),
            ),
            bottomNavigationBar: const CustomBottomBar(),
          );
        } else {
          return LoginScreen(
            signInUseCase: signInUseCase,
            signUpUseCase: signUpUseCase,
          );
        }
      },
    );
  }
}

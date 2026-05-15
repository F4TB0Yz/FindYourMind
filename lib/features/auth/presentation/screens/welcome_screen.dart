import 'package:find_your_mind/config/theme/app_text_styles.dart';
import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/features/auth/presentation/screens/login_screen.dart';
import 'package:find_your_mind/features/auth/presentation/screens/register_screen.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/auth_divider.dart';
import 'package:find_your_mind/shared/presentation/widgets/layouts/feature_layout.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  final SignInWithEmailUseCase signInUseCase;
  final SignUpWithEmailUseCase signUpUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;

  const WelcomeScreen({
    super.key,
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signInWithGoogleUseCase,
  });

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Future<void> _onGooglePressed() async {
    final result = await widget.signInWithGoogleUseCase();
    if (mounted) {
      result.fold(
        (failure) => CustomToast.showToast(context: context, message: failure.message),
        (_) => CustomToast.showToast(context: context, message: 'Redirigiendo a Google...'),
      );
    }
  }

  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(signInUseCase: widget.signInUseCase),
      ),
    );
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(signUpUseCase: widget.signUpUseCase),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: cs.surface,
      body: FeatureLayout(
        scrollable: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 72),
              Center(
                child: Image.asset('assets/images/app_logo.png', width: 120),
              ),
              const SizedBox(height: 28),
              Text(
                'Find Your Mind',
                style: GoogleFonts.fraunces(
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Fortalece tu mente, un hábito a la vez',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              _Card(
                isDark: isDark,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FilledButton(
                        onPressed: _goToLogin,
                        child: Text(
                          'Iniciar sesión',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            color: cs.onPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton(
                        onPressed: _goToRegister,
                        child: Text(
                          'Crear cuenta',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const AuthDivider(),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        onPressed: _onGooglePressed,
                        style: OutlinedButton.styleFrom(
                          backgroundColor: cs.surfaceContainer,
                          side: BorderSide(color: cs.outlineVariant),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/google.svg',
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Continuar con Google',
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color: cs.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const _Card({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.06),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

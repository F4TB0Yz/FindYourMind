import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/features/auth/presentation/screens/register_screen.dart';
import 'package:find_your_mind/features/auth/presentation/utils/auth_error_helper.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/custom_auth_button.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/custom_field.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatefulWidget {
  final SignInWithEmailUseCase signInUseCase;
  final SignUpWithEmailUseCase signUpUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;

  const LoginScreen({
    super.key,
    required this.signInUseCase,
    required this.signUpUseCase,
    required this.signInWithGoogleUseCase,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _passwordFocusNode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _fieldsAreValid() {
    return _emailController.text.trim().isNotEmpty &&
        _passwordController.text.trim().isNotEmpty;
  }

  void _showError(String message) {
    if (!mounted) return;
    CustomToast.showToast(context: context, message: message);
  }

  Future<void> _onLoginPressed() async {
    if (!_fieldsAreValid()) {
      _showError('Por favor completa todos los campos');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await widget.signInUseCase(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        CustomToast.showToast(context: context, message: '¡Bienvenido!');
      }
    } catch (e) {
      _showError(getAuthErrorMessage(e.toString()));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onGoogleLoginPressed() async {
    try {
      await widget.signInWithGoogleUseCase();
      if (mounted) {
        CustomToast.showToast(
          context: context,
          message: 'Redirigiendo a Google...',
        );
      }
    } catch (e) {
      _showError(getAuthErrorMessage(e.toString()));
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(
          signUpUseCase: widget.signUpUseCase,
          signInUseCase: widget.signInUseCase,
          signInWithGoogleUseCase: widget.signInWithGoogleUseCase,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1117),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 48),
              Center(
                child: Image.asset('assets/images/app_logo.png', width: 150),
              ),
              const SizedBox(height: 32),
              const Text(
                'Inicia sesión',
                style: TextStyle(
                  color: Color(0xFFc9d1d9),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Ingresa tus credenciales para continuar',
                style: TextStyle(
                  color: Color(0xFF8b949e),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              AuthInputField(
                controller: _emailController,
                label: 'Correo electrónico',
                hint: 'tu@correo.com',
                textInputAction: TextInputAction.next,
                onSubmitted: () => _passwordFocusNode.requestFocus(),
              ),
              const SizedBox(height: 12),
              AuthInputField(
                controller: _passwordController,
                label: 'Contraseña',
                hint: '••••••••',
                isPassword: true,
                focusNode: _passwordFocusNode,
                textInputAction: TextInputAction.done,
                onSubmitted: _onLoginPressed,
              ),
              const SizedBox(height: 20),
              AuthPrimaryButton(
                onTap: _onLoginPressed,
                isLoading: _isLoading,
                child: const Text(
                  'Iniciar sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _OrDivider(),
              const SizedBox(height: 12),
              AuthSecondaryButton(
                onTap: _onGoogleLoginPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'assets/icons/google.svg',
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Continuar con Google',
                      style: TextStyle(
                        color: Color(0xFFc9d1d9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '¿No tienes una cuenta?',
                      style: TextStyle(
                        color: Color(0xFF8b949e),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    TextButton(
                      onPressed: _goToRegister,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          color: Color(0xFF58a6ff),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
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

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Divider(color: Color(0xFF30363d), thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'o',
            style: TextStyle(color: Color(0xFF8b949e), fontSize: 12),
          ),
        ),
        Expanded(
          child: Divider(color: Color(0xFF30363d), thickness: 1),
        ),
      ],
    );
  }
}

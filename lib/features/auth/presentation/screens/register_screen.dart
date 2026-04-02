import 'package:find_your_mind/core/utils/validators.dart';
import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/custom_auth_button.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/custom_field.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Capa: Presentation → Screens
/// Pantalla de registro de nuevos usuarios.
/// Utiliza [Form] y [GlobalKey<FormState>] para validación robusta de campos,
/// delegando las reglas de validación a [AppValidators] (Core → Utils).
class RegisterScreen extends StatefulWidget {
  final SignUpWithEmailUseCase signUpUseCase;
  final SignInWithEmailUseCase signInUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;

  const RegisterScreen({
    super.key,
    required this.signUpUseCase,
    required this.signInUseCase,
    required this.signInWithGoogleUseCase,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
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

  void _showError(String message) {
    if (!mounted) return;
    CustomToast.showToast(context: context, message: message);
  }

  Future<void> _onRegisterPressed() async {
    // Dispara la validación de todos los campos del Form.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final result = await widget.signUpUseCase(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (mounted) {
      setState(() => _isLoading = false);
      result.fold(
        (failure) => _showError(failure.message),
        (_) {
          CustomToast.showToast(context: context, message: '¡Cuenta creada!');
          Navigator.of(context).pop();
        },
      );
    }
  }

  Future<void> _onGoogleRegisterPressed() async {
    final result = await widget.signInWithGoogleUseCase();
    if (mounted) {
      result.fold(
        (failure) => _showError(failure.message),
        (_) => CustomToast.showToast(
          context: context,
          message: 'Redirigiendo a Google...',
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0d1117),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Center(
                  child: Image.asset('assets/images/app_logo.png', width: 150),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Crear cuenta',
                  style: TextStyle(
                    color: Color(0xFFc9d1d9),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Ingresa tus datos para registrarte',
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
                  validator: AppValidators.email,
                ),
                const SizedBox(height: 12),
                AuthInputField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  hint: 'Mínimo 6 caracteres',
                  isPassword: true,
                  focusNode: _passwordFocusNode,
                  textInputAction: TextInputAction.done,
                  onSubmitted: _onRegisterPressed,
                  validator: AppValidators.password,
                ),
                const SizedBox(height: 20),
                AuthPrimaryButton(
                  onTap: _onRegisterPressed,
                  isLoading: _isLoading,
                  child: const Text(
                    'Crear cuenta',
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
                  onTap: _onGoogleRegisterPressed,
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
                        '¿Ya tienes una cuenta?',
                        style: TextStyle(
                          color: Color(0xFF8b949e),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Inicia sesión',
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
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: Divider(color: Color(0xFF30363d), thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'o',
            style: TextStyle(color: Color(0xFF8b949e), fontSize: 12),
          ),
        ),
        Expanded(child: Divider(color: Color(0xFF30363d), thickness: 1)),
      ],
    );
  }
}
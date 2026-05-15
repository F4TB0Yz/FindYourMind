import 'package:find_your_mind/config/theme/app_text_styles.dart';
import 'package:find_your_mind/core/utils/validators.dart';
import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/custom_auth_button.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/custom_field.dart';
import 'package:find_your_mind/shared/presentation/widgets/layouts/feature_layout.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  final SignUpWithEmailUseCase signUpUseCase;

  const RegisterScreen({
    super.key,
    required this.signUpUseCase,
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: FeatureLayout(
        scrollable: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 58),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                    splashRadius: 20,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Image.asset('assets/images/app_logo.png', width: 96),
                ),
                const SizedBox(height: 28),
                Card(
                  color: cs.surfaceContainer,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: cs.outlineVariant, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Crear cuenta', style: AppTextStyles.h2(context)),
                        const SizedBox(height: 4),
                        Text(
                          'Ingresa tus datos para registrarte',
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            color: cs.onSurfaceVariant,
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
                        const SizedBox(height: 16),
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
                        const SizedBox(height: 24),
                        AuthPrimaryButton(
                          onTap: _onRegisterPressed,
                          isLoading: _isLoading,
                          child: Text(
                            'Crear cuenta',
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              color: cs.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }
}

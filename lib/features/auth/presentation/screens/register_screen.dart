import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/custom_auth_button.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/custom_field.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterScreen extends StatelessWidget {
  final SignUpWithEmailUseCase signUpUseCase;
  final SignInWithEmailUseCase signInUseCase;

  const RegisterScreen({
    super.key,
    required this.signUpUseCase,
    required this.signInUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 50,
              right: 50,
              bottom: 30,
            ),
            child: Column(
              children: [
                Image.asset('assets/images/app_logo.png', width: 200),
            
                const Text(
                  '¿ Aun no tienes una cuenta ? ',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            
                const SizedBox(height: 10),
                
                const Text(
                  'Registrarse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            
                const SizedBox(height: 10),
            
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Correo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500
                      ),
                    ),
            
                    const SizedBox(height: 10),

                    CustomAuthField(controller: emailController),

                    const SizedBox(height: 10),
            
                    const Text(
                      'Contraseña',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500
                      ),
                    ),
            
                    const SizedBox(height: 10),

                    CustomAuthField(controller: passwordController, isPassword: true),
                  ],
                ),
            
            const SizedBox(height: 50),
        
                CustomAuthButton(
                  width: 200,
                  height: 55,
                  onTap: () => onRegisterPressed(context, emailController, passwordController),
                  child: const Text(
                    'Crear Cuenta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),                const SizedBox(height: 20),
            
                CustomAuthButton(
                  width: 200,
                  height: 55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/google.svg',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Continuar con Google',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            
                const SizedBox(height: 30),
            
                const Text(
                  '¿ Ya tienes una cuenta ? ',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            
                const SizedBox(height: 10),
                
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFriendlyErrorMessage(String error) {
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('user already registered') || 
        errorLower.contains('already exists') ||
        errorLower.contains('already been registered')) {
      return 'Este correo ya está registrado';
    }
    
    if (errorLower.contains('email') && errorLower.contains('invalid')) {
      return 'El formato del email no es válido';
    }
    
    if (errorLower.contains('password') && (errorLower.contains('short') || errorLower.contains('weak'))) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    if (errorLower.contains('network') || errorLower.contains('connection')) {
      return 'Error de conexión. Verifica tu internet';
    }
    
    if (errorLower.contains('too many requests')) {
      return 'Demasiados intentos. Intenta más tarde';
    }
    
    return 'Error al crear la cuenta. Intenta nuevamente';
  }

  void onRegisterPressed(BuildContext context, TextEditingController emailController, TextEditingController passwordController) async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    // Validar campos
    if (email.isEmpty || password.isEmpty) {
      if (!context.mounted) return;
      CustomToast.showToast(
        context: context,
        message: 'Por favor completa todos los campos',
      );
      return;
    }

    try {
      await signUpUseCase(email: email, password: password);

      if (context.mounted) {
        CustomToast.showToast(
          context: context,
          message: '¡Registro exitoso!',
        );
        
        // Navegar a la pantalla principal
        Navigator.pushReplacementNamed(context, '/habits');
      }
    } catch (e) {
      if (!context.mounted) return;
      CustomToast.showToast(
        context: context,
        message: _getFriendlyErrorMessage(e.toString()),
      );
    }
  }
}
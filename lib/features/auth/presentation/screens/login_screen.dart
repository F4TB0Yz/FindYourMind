import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/features/auth/presentation/screens/register_screen.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/custom_auth_button.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/custom_field.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatelessWidget {
  final SignInWithEmailUseCase signInUseCase;
  final SignUpWithEmailUseCase signUpUseCase;

  const LoginScreen({
    super.key,
    required this.signInUseCase,
    required this.signUpUseCase,
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
                  '¿ Ya tienes una cuenta ? ',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            
                const SizedBox(height: 10),
                
                const Text(
                  'Inicia sesión',
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
                  onTap: () => onLoginPressed(context, emailController, passwordController),
                  width: 200,
                  height: 55,
                  child: const Text(
                    'Iniciar Sesión',
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
                  '¿ Aun no tienes una cuenta ? ',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            
                const SizedBox(height: 10),
                
                GestureDetector(
                  onTap: () => Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => RegisterScreen(
                        signUpUseCase: signUpUseCase,
                        signInUseCase: signInUseCase,
                      ),
                    )
                  ),
                  child: const Text(
                    'Registrarse',
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

  bool verifyFields(TextEditingController emailController, TextEditingController passwordController) {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      return false;
    }
    return true;
  }

  String _getFriendlyErrorMessage(String error) {
    final errorLower = error.toLowerCase();
    
    if (errorLower.contains('invalid login credentials') || 
        errorLower.contains('invalid_credentials')) {
      return 'Correo o contraseña incorrectos';
    }
    
    if (errorLower.contains('email') && errorLower.contains('invalid')) {
      return 'El formato del email no es válido';
    }
    
    if (errorLower.contains('network') || errorLower.contains('connection')) {
      return 'Error de conexión. Verifica tu internet';
    }
    
    if (errorLower.contains('too many requests')) {
      return 'Demasiados intentos. Intenta más tarde';
    }
    
    if (errorLower.contains('user not found')) {
      return 'Usuario no encontrado';
    }
    
    return 'Error al iniciar sesión. Intenta nuevamente';
  }

  void onLoginPressed(BuildContext context, TextEditingController emailController, TextEditingController passwordController) async {
    if (!verifyFields(emailController, passwordController)) {
      if (context.mounted) {
        CustomToast.showToast(
          context: context,
          message: 'Por favor completa todos los campos',
        );
      }
      return;
    }

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      await signInUseCase(email: email, password: password);
      
      if (context.mounted) {
        CustomToast.showToast(
          context: context,
          message: '¡Inicio de sesión exitoso!',
        );
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
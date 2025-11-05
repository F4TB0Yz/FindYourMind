import 'package:find_your_mind/core/services/auth_service.dart';
import 'package:find_your_mind/features/auth/presentation/screens/register_screen.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/custom_auth_button.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/custom_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginScreen extends StatelessWidget {
  final AuthService authService;

  const LoginScreen({super.key, required this.authService});

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
                  width: 150,
                  child: const Text(
                    'Iniciar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            
                const SizedBox(height: 20),
            
                CustomAuthButton(
                  child: SvgPicture.asset(
                    'assets/icons/google.svg',
                    width: 30,
                    height: 30,
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
                      builder: (context) => RegisterScreen(authService: authService),
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

  void onLoginPressed(BuildContext context, TextEditingController emailController, TextEditingController passwordController) async {
    if (!verifyFields(emailController, passwordController)) {
      return;
    }

    final email = emailController.text;
    final password = passwordController.text;

    try {
      await authService.signInWithEmail(email, password); 
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al iniciar sesión: $e'),
        ),
      );
    }
  }
}
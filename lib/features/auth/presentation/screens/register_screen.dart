import 'package:find_your_mind/core/services/auth_service.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/custom_auth_button.dart';
import 'package:find_your_mind/features/auth/presentation/widgets/custom_field.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habits_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatelessWidget {
  final AuthService authService;

  const RegisterScreen({super.key, required this.authService});

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
                  width: 150,
                  onTap: () => onRegisterPressed(context, emailController, passwordController),
                  child: const Text(
                    'Registrarse',
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

  void onRegisterPressed(BuildContext context, TextEditingController emailController, TextEditingController passwordController) async {
    final String email = emailController.text.trim();
    final String password = passwordController.text.trim();

    try {
      final User? user = await authService.signUpWithEmail(email, password);

      if (user != null && context.mounted) {
        // Registro exitoso, navegar a la pantalla principal
        Navigator.push(
          context, 
          MaterialPageRoute(
            builder: (context) => const HabitsScreen(),
          )
        );
      }

      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      // Manejar errores (mostrar mensaje al usuario, etc.)
    }
  }
}
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para iniciar sesión
/// Responsable de orquestar la lógica de login
class SignInWithEmailUseCase {
  final AuthRepository authRepository;

  SignInWithEmailUseCase({required this.authRepository});

  /// Ejecuta el caso de uso de login
  /// Parámetros:
  ///   - email: Email del usuario
  ///   - password: Contraseña del usuario
  /// Retorna:
  ///   - UserEntity si el login fue exitoso
  /// Lanza:
  ///   - Excepciones si hay errores en la autenticación
  Future<UserEntity> call({required String email, required String password}) async {
    // Validar email no vacío
    if (email.isEmpty) {
      throw ArgumentError('El email no puede estar vacío');
    }

    // Validar contraseña no vacía
    if (password.isEmpty) {
      throw ArgumentError('La contraseña no puede estar vacía');
    }

    // Validar formato básico del email
    if (!_isValidEmail(email)) {
      throw ArgumentError('El formato del email no es válido');
    }

    // Delegar al repositorio
    return await authRepository.signInWithEmail(email, password);
  }

  /// Valida el formato básico del email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

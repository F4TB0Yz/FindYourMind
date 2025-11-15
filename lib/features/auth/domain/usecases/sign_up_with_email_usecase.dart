import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para registrar un nuevo usuario
/// Responsable de orquestar la lógica de registro
class SignUpWithEmailUseCase {
  final AuthRepository authRepository;

  SignUpWithEmailUseCase({required this.authRepository});

  /// Ejecuta el caso de uso de registro
  /// Parámetros:
  ///   - email: Email del nuevo usuario
  ///   - password: Contraseña del nuevo usuario
  /// Retorna:
  ///   - UserEntity si el registro fue exitoso
  /// Lanza:
  ///   - Excepciones si hay errores en el registro
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

    // Validar contraseña mínima
    if (password.length < 6) {
      throw ArgumentError('La contraseña debe tener al menos 6 caracteres');
    }

    // Delegar al repositorio
    return await authRepository.signUpWithEmail(email, password);
  }

  /// Valida el formato básico del email
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}

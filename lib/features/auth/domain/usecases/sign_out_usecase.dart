import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para cerrar sesión
/// Responsable de orquestar la lógica de logout
class SignOutUseCase {
  final AuthRepository authRepository;

  SignOutUseCase({required this.authRepository});

  /// Ejecuta el caso de uso de logout
  /// Cierra la sesión actual del usuario
  /// Lanza:
  ///   - Excepciones si hay errores al cerrar sesión
  Future<void> call() async {
    return await authRepository.signOut();
  }
}

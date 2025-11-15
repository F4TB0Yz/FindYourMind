import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para obtener el usuario actual autenticado
/// Responsable de recuperar el usuario actualmente logueado
class GetCurrentUserUseCase {
  final AuthRepository authRepository;

  GetCurrentUserUseCase({required this.authRepository});

  /// Ejecuta el caso de uso para obtener el usuario actual
  /// Retorna:
  ///   - UserEntity si hay un usuario autenticado
  ///   - null si no hay sesión activa
  /// Lanza:
  ///   - Excepciones si hay errores al obtener el usuario
  Future<UserEntity?> call() async {
    return await authRepository.getCurrentUser();
  }
}

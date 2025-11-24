import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para autenticar usuario con Google
/// Responsable de orquestar la lógica de autenticación con Google
class SignInWithGoogleUseCase {
  final AuthRepository authRepository;

  SignInWithGoogleUseCase({required this.authRepository});

  /// Ejecuta el caso de uso de autenticación con Google
  /// Retorna:
  ///   - UserEntity si la autenticación fue exitosa
  /// Lanza:
  ///   - Excepciones si hay errores en la autenticación
  Future<UserEntity> call() async {
    print('🚀 [USECASE] SignInWithGoogle - Iniciando autenticación con Google');
    
    try {
      final user = await authRepository.signInWithGoogle();
      print('✅ [USECASE] SignInWithGoogle - Autenticación exitosa');
      print('   Usuario: ${user.email}');
      return user;
    } catch (e) {
      print('❌ [USECASE] SignInWithGoogle - Error: $e');
      rethrow;
    }
  }
}

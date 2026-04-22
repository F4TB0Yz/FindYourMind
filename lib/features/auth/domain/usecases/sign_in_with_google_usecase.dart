import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para autenticar usuario con Google
/// Responsable de orquestar la lógica de autenticación con Google
class SignInWithGoogleUseCase {
  final AuthRepository authRepository;

  SignInWithGoogleUseCase({required this.authRepository});

  /// Ejecuta el caso de uso de autenticación con Google
  Future<Either<Failure, UserEntity>> call() async {
    // Delegar al repositorio
    return await authRepository.signInWithGoogle();
  }
}

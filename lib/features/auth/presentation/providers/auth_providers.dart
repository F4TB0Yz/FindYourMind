import 'package:find_your_mind/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';
import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/core/services/auth_service.dart';

/// Crea el repositorio de autenticación
/// Este se proporciona a través del árbol de providers
AuthRepository createAuthRepository(AuthService authService) {
  return AuthRepositoryImpl(authService: authService);
}

/// Crea el caso de uso SignInWithEmail
SignInWithEmailUseCase createSignInWithEmailUseCase(AuthRepository authRepository) {
  return SignInWithEmailUseCase(authRepository: authRepository);
}

/// Crea el caso de uso SignUpWithEmail
SignUpWithEmailUseCase createSignUpWithEmailUseCase(AuthRepository authRepository) {
  return SignUpWithEmailUseCase(authRepository: authRepository);
}

/// Crea el caso de uso SignOut
SignOutUseCase createSignOutUseCase(AuthRepository authRepository) {
  return SignOutUseCase(authRepository: authRepository);
}

/// Crea el caso de uso GetCurrentUser
GetCurrentUserUseCase createGetCurrentUserUseCase(AuthRepository authRepository) {
  return GetCurrentUserUseCase(authRepository: authRepository);
}

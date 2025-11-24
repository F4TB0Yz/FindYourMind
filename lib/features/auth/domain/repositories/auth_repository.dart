import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';

/// Repositorio abstracto para operaciones de autenticación
/// Define el contrato que debe cumplir cualquier implementación de autenticación
abstract class AuthRepository {
  /// Obtiene el usuario actualmente autenticado
  Future<UserEntity?> getCurrentUser();

  /// Inicia sesión con email y contraseña
  /// Lanza excepciones en caso de error
  Future<UserEntity> signInWithEmail(String email, String password);

  /// Registra un nuevo usuario con email y contraseña
  /// Lanza excepciones en caso de error
  Future<UserEntity> signUpWithEmail(String email, String password);

  /// Inicia sesión con Google
  /// Lanza excepciones en caso de error
  Future<UserEntity> signInWithGoogle();

  /// Cierra la sesión actual del usuario
  Future<void> signOut();

  /// Stream de cambios en el estado de autenticación
  /// Emite el usuario autenticado o null si no hay sesión
  Stream<UserEntity?> get onAuthStateChange;
}

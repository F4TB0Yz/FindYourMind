import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';

/// Repositorio abstracto para operaciones de autenticación
/// Define el contrato que debe cumplir cualquier implementación de autenticación
abstract class AuthRepository {
  /// Obtiene el usuario actualmente autenticado
  Future<UserEntity?> getCurrentUser();

  /// Inicia sesión con email y contraseña
  Future<Either<Failure, UserEntity>> signInWithEmail(String email, String password);

  /// Registra un nuevo usuario con email y contraseña
  Future<Either<Failure, UserEntity>> signUpWithEmail(String email, String password);

  /// Inicia sesión con Google
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Cierra la sesión actual del usuario
  Future<Either<Failure, void>> signOut();

  /// Stream de cambios en el estado de autenticación
  /// Emite el usuario autenticado o null si no hay sesión
  Stream<UserEntity?> get onAuthStateChange;
}

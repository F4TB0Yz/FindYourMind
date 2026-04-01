import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/error/failures.dart';
import 'package:find_your_mind/core/services/auth_service.dart';
import 'package:find_your_mind/features/auth/data/datasources/users_remote_datasource.dart';
import 'package:find_your_mind/features/auth/data/models/user_model.dart';
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

/// Implementación del repositorio de autenticación
/// Adapta la interfaz del AuthService al contrato del AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;
  final UsersRemoteDataSource usersDataSource;

  AuthRepositoryImpl({
    required this.authService,
    required this.usersDataSource,
  });

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = authService.currentUser;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      // Para getCurrentUser seguimos retornando null o lanzando si es crítico
      // ya que la interfaz base lo tiene como Future<UserEntity?>
      return null;
    }
  }

  @override
  Stream<UserEntity?> get onAuthStateChange {
    return authService.onAuthStateChange.map((authState) {
      final user = authState.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    });
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail(String email, String password) async {
    try {
      final user = await authService.signInWithEmail(email, password);
      if (user == null) {
        return Left(ServerFailure(message: 'No se pudo autenticar al usuario'));
      }

      // Verificar si el usuario existe en la tabla 'users'
      try {
        final exists = await usersDataSource.userExists(user.id);
        if (!exists) {
          await usersDataSource.createUser(
            id: user.id,
            email: user.email!,
            nombre: null,
          );
        }
      } catch (e) {
        debugPrint('⚠️ Advertencia al verificar/crear usuario en tabla users: $e');
      }

      return Right(UserModel.fromSupabaseUser(user));
    } catch (e) {
      return Left(ServerFailure(message: _mapAuthError(e.toString())));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUpWithEmail(String email, String password) async {
    try {
      final user = await authService.signUpWithEmail(email, password);
      
      if (user == null) {
        return Left(ServerFailure(message: 'No se pudo registrar al usuario'));
      }
      
      try {
        await Future.delayed(const Duration(milliseconds: 500));
        final exists = await usersDataSource.userExists(user.id);
        
        if (!exists) {
          await usersDataSource.createUser(
            id: user.id,
            email: user.email!,
            nombre: '',
          );
        }
      } catch (userTableError) {
        debugPrint('⚠️ Advertencia: No se pudo verificar en tabla users: $userTableError');
      }

      return Right(UserModel.fromSupabaseUser(user));
    } catch (e) {
      if (e.toString().contains('Database error saving new user')) {
        return Left(ServerFailure(message: 'Error de configuración en el servidor. Contacte soporte.'));
      }
      return Left(ServerFailure(message: _mapAuthError(e.toString())));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      await authService.signInWithGoogle();
      
      // Retornamos un UserEntity temporal para indicar que el proceso inició correctamente
      return Right(UserEntity(
        id: 'oauth-pending',
        email: 'oauth-pending@temp.com',
        createdAt: DateTime.now(),
      ));
    } catch (e) {
      return Left(ServerFailure(message: _mapAuthError(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await authService.signOut();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Error al cerrar sesión: ${e.toString()}'));
    }
  }

  /// Mapea errores crudos a mensajes amigables según la regla #28
  String _mapAuthError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Credenciales inválidas. Verifica tu email y contraseña.';
    } else if (error.contains('Email not confirmed')) {
      return 'Tu email no ha sido confirmado. Por favor revisa tu bandeja de entrada.';
    } else if (error.contains('User already registered')) {
      return 'Este correo ya está registrado.';
    } else if (error.contains('Password should be')) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    } else if (error.contains('network_error')) {
      return 'Error de red. Verifica tu conexión.';
    }
    return 'Ocurrió un error inesperado en la autenticación.';
  }
}

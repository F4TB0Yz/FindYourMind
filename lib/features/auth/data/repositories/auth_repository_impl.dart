import 'package:find_your_mind/core/services/auth_service.dart';
import 'package:find_your_mind/features/auth/data/models/user_model.dart';
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';

/// Implementación del repositorio de autenticación
/// Adapta la interfaz del AuthService al contrato del AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final AuthService authService;

  AuthRepositoryImpl({required this.authService});

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final user = authService.currentUser;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Stream<UserEntity?> get onAuthStateChange {
    return authService.onAuthStateChange.map((authState) {
      // AuthState tiene un campo 'user' que puede ser null
      final user = authState.session?.user;
      if (user == null) return null;
      return UserModel.fromSupabaseUser(user);
    });
  }

  @override
  Future<UserEntity> signInWithEmail(String email, String password) async {
    try {
      final user = await authService.signInWithEmail(email, password);
      if (user == null) {
        throw Exception('No se pudo autenticar al usuario');
      }
      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> signUpWithEmail(String email, String password) async {
    try {
      final user = await authService.signUpWithEmail(email, password);
      if (user == null) {
        throw Exception('No se pudo registrar al usuario');
      }
      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await authService.signOut();
    } catch (e) {
      rethrow;
    }
  }
}

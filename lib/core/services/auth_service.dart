import 'package:supabase_flutter/supabase_flutter.dart';

/// Interfaz simple para el servicio de autenticación.
/// Implementaciones concretas (p. ej. Supabase) deben proporcionar
/// los métodos definidos aquí.
abstract class AuthService {
  /// Usuario actualmente autenticado (o null si no hay sesión).
  User? get currentUser;

  /// Inicia sesión con email y contraseña. Retorna el usuario si fue exitosa.
  Future<User?> signInWithEmail(String email, String password);

  Future<User?>   signUpWithEmail(String email, String password);

  /// Inicia sesión con Google. Retorna el usuario si fue exitosa.
  Future<User?> signInWithGoogle();

  /// Cierra la sesión actual.
  Future<void> signOut();

  /// Stream de cambios en el estado de autenticación emitido por el proveedor.
  /// Usamos `AuthState` porque es lo que expone `supabase_flutter`.
  Stream<AuthState> get onAuthStateChange;
}

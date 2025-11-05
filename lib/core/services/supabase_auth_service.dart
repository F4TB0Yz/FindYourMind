import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

/// Implementación de [AuthService] usando Supabase.
class SupabaseAuthService implements AuthService {
  final SupabaseClient _client;

  SupabaseAuthService(this._client);

  @override
  User? get currentUser => _client.auth.currentUser;

  @override
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      // signInWithPassword es la API de supabase_flutter v2.x
      await _client.auth.signInWithPassword(email: email, password: password);
      return _client.auth.currentUser;
    } catch (e) {
      // Propagar el error para que la capa superior lo maneje
      rethrow;
    }
  }

  @override
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      await _client.auth.signUp(email: email, password: password);
      return _client.auth.currentUser;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

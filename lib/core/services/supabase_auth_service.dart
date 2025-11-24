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
    print('🔐 [AUTH_SERVICE] signUpWithEmail - Iniciando para: $email');
    
    try {
      print('📡 [AUTH_SERVICE] Llamando a Supabase.auth.signUp...');
      final response = await _client.auth.signUp(email: email, password: password);
      
      print('📨 [AUTH_SERVICE] Respuesta recibida de Supabase');
      print('   Session: ${response.session != null ? "✅" : "❌"}');
      print('   User: ${response.user != null ? "✅" : "❌"}');
      
      if (response.user != null) {
        print('✅ [AUTH_SERVICE] Usuario creado: ${response.user!.id}');
      }
      
      final currentUser = _client.auth.currentUser;
      print('👤 [AUTH_SERVICE] currentUser: ${currentUser?.id ?? "null"}');
      
      return currentUser;
    } catch (e, stackTrace) {
      print('❌ [AUTH_SERVICE] Error en signUpWithEmail: $e');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    print('🔐 [AUTH_SERVICE] signInWithGoogle - Iniciando autenticación con Google');
    
    try {
      print('📡 [AUTH_SERVICE] Llamando a Supabase.auth.signInWithOAuth...');
      
      // Configurar OAuth con Google
      // IMPORTANTE: Debes configurar Google OAuth en tu proyecto Supabase:
      // 1. Ve a: Supabase Dashboard > Authentication > Providers > Google
      // 2. Habilita Google provider
      // 3. Agrega Client ID y Client Secret de Google Cloud Console
      // 4. Configura la URL de redirección autorizada
      
      // signInWithOAuth abre el navegador para autenticación
      // Usar la URL de callback de Supabase directamente
      final result = await _client.auth.signInWithOAuth(
        OAuthProvider.google,
      );
      
      print('📨 [AUTH_SERVICE] OAuth iniciado - URL: ${result ? "generada" : "error"}');
      print('⏳ [AUTH_SERVICE] Esperando que el usuario complete la autenticación...');
      print('ℹ️  [AUTH_SERVICE] El usuario será autenticado cuando regrese de Google');
      print('ℹ️  [AUTH_SERVICE] El AuthScreen detectará el cambio automáticamente');
      
      // signInWithOAuth solo abre el navegador, no espera el resultado
      // El usuario será autenticado cuando regrese del navegador
      // El StreamBuilder en AuthScreen detectará el cambio automáticamente
      // Por ahora retornamos null, lo cual es esperado
      return null;
    } catch (e, stackTrace) {
      print('❌ [AUTH_SERVICE] Error en signInWithGoogle: $e');
      print('   Stack trace: $stackTrace');
      
      // Dar un error más específico si es problema de configuración
      if (e.toString().contains('validation_failed') || 
          e.toString().contains('missing OAuth secret')) {
        throw Exception(
          'Google OAuth no está configurado en Supabase. '
          'Por favor configura Google provider en: '
          'Supabase Dashboard > Authentication > Providers > Google'
        );
      }
      
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

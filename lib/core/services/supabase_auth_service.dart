import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_service.dart';

/// Implementación de [AuthService] usando Supabase.
class SupabaseAuthService implements AuthService {
  final SupabaseClient _client;
  final GoogleSignIn _googleSignIn;

  // Client ID de tipo WEB para obtener idToken válido para Supabase
  static const String _webClientId = '814008895879-t55qstqd6npm5rkneec0rt5t7vcg011o.apps.googleusercontent.com';

  SupabaseAuthService(this._client)
      : _googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile', 'openid'],
          serverClientId: _webClientId,
        );

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
    AppLogger.i('🔐 [AUTH_SERVICE] signUpWithEmail - Iniciando para: $email');

    try {
      AppLogger.i('📡 [AUTH_SERVICE] Llamando a Supabase.auth.signUp...');
      final response = await _client.auth.signUp(email: email, password: password);

      AppLogger.i('📨 [AUTH_SERVICE] Respuesta recibida de Supabase');
      AppLogger.d('   Session: ${response.session != null ? "✅" : "❌"}');
      AppLogger.d('   User: ${response.user != null ? "✅" : "❌"}');

      if (response.user != null) {
        AppLogger.i('✅ [AUTH_SERVICE] Usuario creado: ${response.user!.id}');
      }

      final currentUser = _client.auth.currentUser;
      AppLogger.d('👤 [AUTH_SERVICE] currentUser: ${currentUser?.id ?? "null"}');

      return currentUser;
    } catch (e, stackTrace) {
      AppLogger.e('Error en signUpWithEmail', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    AppLogger.i('🔐 [AUTH_SERVICE] signInWithGoogle - Usando SDK Nativo de Google');

    try {
      // Iniciar flujo nativo de Google Sign-In
      // Esto muestra el selector de cuentas nativo de Google sin navegador
      AppLogger.i('📡 [AUTH_SERVICE] Iniciando GoogleSignIn...');

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        AppLogger.w('⚠️ [AUTH_SERVICE] Usuario canceló el inicio de sesión');
        throw Exception('Inicio de sesión cancelado por el usuario');
      }

      AppLogger.i('✅ [AUTH_SERVICE] Usuario seleccionado: ${googleUser.email}');

      // Obtener tokens de autenticación
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        AppLogger.e('❌ [AUTH_SERVICE] No se pudo obtener idToken de Google');
        throw Exception('Error al obtener credenciales de Google');
      }

      AppLogger.i('✅ [AUTH_SERVICE] Tokens obtenidos de Google');

      // Autenticar con Supabase usando el idToken de Google
      // Esto vincula la cuenta de Google con Supabase Auth
      AppLogger.i('📡 [AUTH_SERVICE] Autenticando con Supabase usando idToken...');

      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) {
        AppLogger.e('❌ [AUTH_SERVICE] Supabase no retornó usuario');
        throw Exception('Error al autenticar con Supabase');
      }

      AppLogger.i('✅ [AUTH_SERVICE] Autenticación exitosa: ${response.user!.id}');

      return response.user;
    } on Exception catch (e) {
      // Si es cancelación del usuario, no es un error real
      if (e.toString().contains('canceled') ||
          e.toString().contains('cancelled') ||
          e.toString().contains('cancelado')) {
        AppLogger.i('👤 [AUTH_SERVICE] Usuario canceló el flujo');
        return null;
      }

      AppLogger.e('Error en signInWithGoogle', error: e);

      // Dar un error más específico si es problema de configuración
      if (e.toString().contains('sign_in_failed') ||
          e.toString().contains('PlatformException')) {
        throw Exception(
          'Error al iniciar sesión con Google. '
          'Verifica que Google Sign-In esté configurado correctamente '
          'en Google Cloud Console y que el SHA-1 esté registrado.',
        );
      }

      rethrow;
    } catch (e, stackTrace) {
      AppLogger.e('Error inesperado en signInWithGoogle', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    // Cerrar sesión en Google también
    try {
      await _googleSignIn.signOut();
      AppLogger.i('👋 [AUTH_SERVICE] Sesión de Google cerrada');
    } catch (e) {
      AppLogger.w('⚠️ [AUTH_SERVICE] Error al cerrar sesión de Google: $e');
      // No propagar error, continuar con signOut de Supabase
    }

    await _client.auth.signOut();
  }
}

import 'package:find_your_mind/core/config/database_helper.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';

/// Caso de uso para cerrar sesión
/// Responsable de orquestar la lógica de logout
class SignOutUseCase {
  final AuthRepository authRepository;
  final DatabaseHelper databaseHelper;

  SignOutUseCase({
    required this.authRepository,
    required this.databaseHelper,
  });

  /// Ejecuta el caso de uso de logout
  /// Cierra la sesión actual del usuario y limpia los datos locales
  /// Lanza:
  ///   - Excepciones si hay errores al cerrar sesión
  Future<void> call() async {
    print('🚪 [USECASE] SignOut - Iniciando cierre de sesión');
    
    try {
      // 1. Limpiar SQLite antes de cerrar sesión
      print('🧹 [USECASE] Limpiando datos locales...');
      await databaseHelper.clearAllTables();
      print('✅ [USECASE] Datos locales limpiados');
      
      // 2. Cerrar sesión en Supabase
      print('🔓 [USECASE] Cerrando sesión en Supabase...');
      await authRepository.signOut();
      print('✅ [USECASE] Sesión cerrada exitosamente');
    } catch (e) {
      print('❌ [USECASE] Error en SignOut: $e');
      rethrow;
    }
  }
}

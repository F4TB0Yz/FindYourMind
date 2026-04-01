import 'package:dartz/dartz.dart';
import 'package:find_your_mind/core/config/database_helper.dart';
import 'package:find_your_mind/core/error/failures.dart';
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
  Future<Either<Failure, void>> call() async {
    try {
      // 1. Limpiar SQLite antes de cerrar sesión
      await databaseHelper.clearAllTables();
      
      // 2. Cerrar sesión en Supabase
      return await authRepository.signOut();
    } catch (e) {
      return Left(CacheFailure(message: 'Error al limpiar datos locales: ${e.toString()}'));
    }
  }
}

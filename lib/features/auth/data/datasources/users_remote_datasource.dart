import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Capa: Data → Datasources
/// Datasource remoto de usuarios sobre la tabla 'users' de Supabase.
/// Toda la comunicación con el servidor se encapsula aquí.

/// Interfaz para el datasource remoto de usuarios
abstract class UsersRemoteDataSource {
  /// Crea un nuevo usuario en la tabla 'users' de Supabase
  ///
  /// [id] - UUID del usuario de auth.users
  /// [email] - Email del usuario
  /// [nombre] - Nombre opcional del usuario
  Future<void> createUser({
    required String id,
    required String email,
    String? nombre,
  });

  /// Verifica si un usuario existe en la tabla 'users'
  Future<bool> userExists(String id);

  /// Actualiza la información de un usuario
  Future<void> updateUser({
    required String id,
    String? nombre,
  });
}

/// Implementación del datasource remoto usando Supabase
class UsersRemoteDataSourceImpl implements UsersRemoteDataSource {
  final SupabaseClient client;

  UsersRemoteDataSourceImpl({required this.client});

  @override
  Future<void> createUser({
    required String id,
    required String email,
    String? nombre,
  }) async {
    AppLogger.d('[DATASOURCE] createUser — ID: $id | Email: $email | Nombre: $nombre');

    try {
      final data = {
        'id': id,
        'correo': email,
        'nombre': nombre,
        'fecha_registro': DateTime.now().toIso8601String(),
      };

      AppLogger.d('[DATASOURCE] Insertando en tabla users: $data');

      await client.from('users').insert(data);

      AppLogger.i('[DATASOURCE] Usuario insertado exitosamente en tabla users');
    } catch (e, stackTrace) {
      AppLogger.e(
        '[DATASOURCE] Error al crear usuario en tabla users',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Error al crear usuario en tabla users: $e');
    }
  }

  @override
  Future<bool> userExists(String id) async {
    AppLogger.d('[DATASOURCE] userExists — Verificando ID: $id');

    try {
      final response = await client
          .from('users')
          .select('id')
          .eq('id', id)
          .maybeSingle();

      final exists = response != null;
      AppLogger.d('[DATASOURCE] Usuario ${exists ? "existe" : "NO existe"} en tabla users');

      return exists;
    } catch (e, stackTrace) {
      AppLogger.e(
        '[DATASOURCE] Error al verificar existencia del usuario',
        error: e,
        stackTrace: stackTrace,
      );
      throw Exception('Error al verificar existencia del usuario: $e');
    }
  }

  @override
  Future<void> updateUser({
    required String id,
    String? nombre,
  }) async {
    try {
      final Map<String, dynamic> updates = {};

      if (nombre != null) {
        updates['nombre'] = nombre;
      }

      if (updates.isNotEmpty) {
        await client
            .from('users')
            .update(updates)
            .eq('id', id);
      }
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }
}

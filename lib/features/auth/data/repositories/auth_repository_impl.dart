import 'package:find_your_mind/core/services/auth_service.dart';
import 'package:find_your_mind/features/auth/data/datasources/users_remote_datasource.dart';
import 'package:find_your_mind/features/auth/data/models/user_model.dart';
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';

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

      // Verificar si el usuario existe en la tabla 'users'
      // Si no existe, crearlo (para usuarios legacy que se registraron antes de esta actualización)
      try {
        final exists = await usersDataSource.userExists(user.id);
        if (!exists) {
          print('ℹ️ Usuario legacy detectado, creando registro en tabla users...');
          await usersDataSource.createUser(
            id: user.id,
            email: user.email!,
            nombre: null,
          );
        }
      } catch (e) {
        // No fallar el login si hay problema con la tabla users
        print('⚠️ Advertencia al verificar/crear usuario en tabla users: $e');
      }

      return UserModel.fromSupabaseUser(user);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserEntity> signUpWithEmail(String email, String password) async {
    print('📦 [REPOSITORY] signUpWithEmail - Iniciando para: $email');
    
    try {
      // 1. Crear usuario en auth.users de Supabase
      print('📡 [REPOSITORY] Llamando a authService.signUpWithEmail...');
      final user = await authService.signUpWithEmail(email, password);
      
      if (user == null) {
        print('❌ [REPOSITORY] AuthService retornó null');
        throw Exception('No se pudo registrar al usuario');
      }
      
      print('✅ [REPOSITORY] Usuario creado en auth.users: ${user.id}');

      // 2. Crear registro en la tabla 'users' personalizada
      // Nota: Si el trigger de Supabase está configurado, esto puede ser redundante
      // pero garantiza la sincronización si el trigger falla
      print('📝 [REPOSITORY] Intentando crear en tabla users (backup)...');
      try {
        // Pequeño delay para dar tiempo al trigger de Supabase
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Verificar si ya existe (creado por el trigger)
        final exists = await usersDataSource.userExists(user.id);
        
        if (!exists) {
          print('ℹ️ [REPOSITORY] Usuario no existe en tabla users, creando...');
          await usersDataSource.createUser(
            id: user.id,
            email: user.email!,
            nombre: '', // String vacío en lugar de null
          );
          print('✅ [REPOSITORY] Usuario creado manualmente en tabla users');
        } else {
          print('✅ [REPOSITORY] Usuario ya existe en tabla users (creado por trigger)');
        }
      } catch (userTableError) {
        // Si falla la creación en la tabla users, loguear pero no fallar
        // El trigger de Supabase debería manejarlo
        print('⚠️ [REPOSITORY] Advertencia: No se pudo verificar/crear en tabla users');
        print('   Error: $userTableError');
        print('   El trigger de Supabase debería manejarlo automáticamente');
      }

      print('🎉 [REPOSITORY] Registro completado, retornando UserEntity');
      return UserModel.fromSupabaseUser(user);
    } catch (e, stackTrace) {
      print('❌ [REPOSITORY] Error en signUpWithEmail: $e');
      print('   Stack trace: $stackTrace');
      
      // Dar mensaje más específico si es error de base de datos
      if (e.toString().contains('Database error saving new user')) {
        print('💡 [REPOSITORY] SUGERENCIA: Ejecuta el script SQL de SUPABASE_FIX_DATABASE_ERROR.sql');
        throw Exception('Error de configuración en Supabase. Contacta al administrador.');
      }
      
      rethrow;
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    print('📦 [REPOSITORY] signInWithGoogle - Iniciando');
    
    try {
      print('📡 [REPOSITORY] Llamando a authService.signInWithGoogle...');
      await authService.signInWithGoogle();
      
      // signInWithGoogle abre el navegador pero no retorna el usuario inmediatamente
      // El usuario será autenticado cuando regrese del navegador
      // El StreamBuilder en AuthScreen lo detectará automáticamente
      print('✅ [REPOSITORY] OAuth iniciado correctamente');
      print('ℹ️  [REPOSITORY] El usuario completará la autenticación en el navegador');
      
      // Retornamos un UserEntity temporal para indicar que el proceso inició correctamente
      // El usuario real se obtendrá del StreamBuilder cuando regrese
      return UserEntity(
        id: 'oauth-pending',
        email: 'oauth-pending@temp.com',
        createdAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      print('❌ [REPOSITORY] Error en signInWithGoogle: $e');
      print('   Stack trace: $stackTrace');
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

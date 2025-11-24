import 'package:find_your_mind/core/config/database_helper.dart';
import 'package:find_your_mind/core/network/network_info.dart';
import 'package:find_your_mind/core/services/sync_service.dart';
import 'package:find_your_mind/features/auth/data/datasources/users_remote_datasource.dart';
import 'package:find_your_mind/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';
import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_local_datasource.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:find_your_mind/features/habits/domain/usecases/create_habit.dart';
import 'package:find_your_mind/features/habits/domain/usecases/decrement_habit_progress_usecase.dart';
import 'package:find_your_mind/features/habits/domain/usecases/delete_habit_usecase.dart';
import 'package:find_your_mind/features/habits/domain/usecases/increment_habit_progress_usecase.dart';
import 'package:find_your_mind/features/habits/domain/usecases/update_habit_usecase.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:find_your_mind/core/services/auth_service.dart';
import 'package:find_your_mind/core/services/supabase_auth_service.dart';

/// Configuración de inyección de dependencias para la funcionalidad de hábitos
/// Implementa el patrón Singleton para garantizar una única instancia de los servicios
class DependencyInjection {
  static DependencyInjection? _instance;
  bool _isInitialized = false;

  // Dependencias compartidas
  late final DatabaseHelper _databaseHelper;
  late final NetworkInfo _networkInfo;
  late final SupabaseClient _supabaseClient;

  // Datasources
  late final HabitsRemoteDataSource _remoteDataSource;
  late final HabitsLocalDatasource _localDataSource;
  late final UsersRemoteDataSource _usersRemoteDataSource;

  // Servicios
  late final SyncService _syncService;
  late final AuthService _authService;

  // Repositorios
  late final HabitRepository _habitRepository;
  late final AuthRepository _authRepository;

  // Casos de uso de Hábitos
  late final CreateHabitUseCase _createHabitUseCase;
  late final UpdateHabitUseCase _updateHabitUseCase;
  late final DeleteHabitUseCase _deleteHabitUseCase;
  late final IncrementHabitProgressUseCase _incrementHabitProgressUseCase;
  late final DecrementHabitProgressUseCase _decrementHabitProgressUseCase;

  // Casos de uso de Autenticación
  late final SignInWithEmailUseCase _signInWithEmailUseCase;
  late final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  late final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  late final SignOutUseCase _signOutUseCase;
  late final GetCurrentUserUseCase _getCurrentUserUseCase;

  DependencyInjection._internal();

  factory DependencyInjection() {
    _instance ??= DependencyInjection._internal();
    return _instance!;
  }

  /// Inicializa todas las dependencias de forma asíncrona
  /// [forceResetDatabase] - Si es true, elimina y recrea la base de datos
  Future<void> initialize({bool forceResetDatabase = false}) async {
    if (_isInitialized) return;

    // 1. Inicializar dependencias base
    _databaseHelper = DatabaseHelper();

    // Inicializar sqflite_ffi primero
    DatabaseHelper.initializeFfi();

    // Si se solicita reset, eliminar la base de datos
    if (forceResetDatabase) {
      print('🔄 [DI] Forzando recreación de la base de datos...');
      try {
        await _databaseHelper.deleteDatabaseFile();
      } catch (e) {
        print('⚠️ [DI] Error al eliminar BD (puede no existir): $e');
      }
    }

    // Asegurar que la BD esté lista
    try {
      await _databaseHelper.database;
    } catch (e) {
      print('⚠️ [DI] Error al abrir la base de datos. Intentando recrear...');
      // Si hay error, eliminar y recrear la base de datos
      try {
        await _databaseHelper.deleteDatabaseFile();
        await _databaseHelper.database;
      } catch (e2) {
        print('❌ [DI] Error crítico al inicializar la base de datos: $e2');
        rethrow;
      }
    }

    _networkInfo = NetworkInfoImpl(InternetConnectionChecker.instance);
    _supabaseClient = Supabase.instance.client;

    // Inicializar servicio de autenticación
    _authService = SupabaseAuthService(_supabaseClient);
    print('✅ [DI] AuthService inicializado');

    // Inicializar datasource de usuarios
    _usersRemoteDataSource = UsersRemoteDataSourceImpl(client: _supabaseClient);
    print('✅ [DI] UsersRemoteDataSource inicializado');

    // Inicializar repositorio de autenticación
    _authRepository = AuthRepositoryImpl(
      authService: _authService,
      usersDataSource: _usersRemoteDataSource,
    );
    print('✅ [DI] AuthRepository inicializado con UsersRemoteDataSource');

    // Inicializar casos de uso de autenticación
    _signInWithEmailUseCase = SignInWithEmailUseCase(authRepository: _authRepository);
    _signUpWithEmailUseCase = SignUpWithEmailUseCase(authRepository: _authRepository);
    _signInWithGoogleUseCase = SignInWithGoogleUseCase(authRepository: _authRepository);
    _signOutUseCase = SignOutUseCase(
      authRepository: _authRepository,
      databaseHelper: _databaseHelper,
    );
    _getCurrentUserUseCase = GetCurrentUserUseCase(authRepository: _authRepository);

    // 2. Inicializar datasources
    _remoteDataSource = HabitsRemoteDataSourceImpl(client: _supabaseClient);
    _localDataSource = HabitsLocalDatasourceImpl(
      databaseHelper: _databaseHelper,
    );

    // 3. Inicializar servicio de sincronización
    _syncService = SyncService(
      dbHelper: _databaseHelper,
      remoteDataSource: _remoteDataSource,
    );

    // 4. Inicializar repositorio con todas las dependencias
    _habitRepository = HabitRepositoryImpl(
      remoteDataSource: _remoteDataSource,
      localDataSource: _localDataSource,
      networkInfo: _networkInfo,
      syncService: _syncService,
    );

    // 5. Inicializar casos de uso
    _createHabitUseCase = CreateHabitUseCase(_habitRepository);
    _updateHabitUseCase = UpdateHabitUseCase(_habitRepository);
    _deleteHabitUseCase = DeleteHabitUseCase(_habitRepository);
    _incrementHabitProgressUseCase = IncrementHabitProgressUseCase(
      _habitRepository,
    );
    _decrementHabitProgressUseCase = DecrementHabitProgressUseCase(
      _habitRepository,
    );

    _isInitialized = true;
  }

  // Getters para acceder a las dependencias
  HabitRepository get habitRepository => _habitRepository;
  AuthRepository get authRepository => _authRepository;
  DatabaseHelper get databaseHelper => _databaseHelper;
  NetworkInfo get networkInfo => _networkInfo;
  SyncService get syncService => _syncService;
  AuthService get authService => _authService;

  // Getters para los casos de uso de Hábitos
  CreateHabitUseCase get createHabitUseCase => _createHabitUseCase;
  UpdateHabitUseCase get updateHabitUseCase => _updateHabitUseCase;
  DeleteHabitUseCase get deleteHabitUseCase => _deleteHabitUseCase;
  IncrementHabitProgressUseCase get incrementHabitProgressUseCase =>
      _incrementHabitProgressUseCase;
  DecrementHabitProgressUseCase get decrementHabitProgressUseCase =>
      _decrementHabitProgressUseCase;

  // Getters para los casos de uso de Autenticación
  SignInWithEmailUseCase get signInWithEmailUseCase => _signInWithEmailUseCase;
  SignUpWithEmailUseCase get signUpWithEmailUseCase => _signUpWithEmailUseCase;
  SignInWithGoogleUseCase get signInWithGoogleUseCase => _signInWithGoogleUseCase;
  SignOutUseCase get signOutUseCase => _signOutUseCase;
  GetCurrentUserUseCase get getCurrentUserUseCase => _getCurrentUserUseCase;
  
  /// Verifica si el sistema de autenticación está correctamente inicializado
  bool get isAuthInitialized => _isInitialized;
}

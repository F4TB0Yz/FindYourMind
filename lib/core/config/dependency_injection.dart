import 'package:find_your_mind/core/database/app_database.dart';
import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:find_your_mind/core/network/network_info.dart';
import 'package:find_your_mind/core/network/supabase_client_wrapper.dart';
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
import 'package:find_your_mind/features/habits/domain/usecases/delete_habit_usecase.dart';
import 'package:find_your_mind/features/habits/domain/usecases/save_habit_progress_usecase.dart';
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
  late final AppDatabase _databaseHelper;
  late final NetworkInfo _networkInfo;
  late final SupabaseClient _supabaseClient;
  late final SupabaseClientWrapper _supabaseClientWrapper;

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
  late final SaveHabitProgressUseCase _saveHabitProgressUseCase;

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
    _databaseHelper = AppDatabase();

    AppDatabase.initializeFfi();

    // Si se solicita reset, eliminar la base de datos
    if (forceResetDatabase) {
      AppLogger.i('🔄 [DI] Forzando recreación de la base de datos...');
      try {
        await _databaseHelper.deleteDatabaseFile();
      } catch (e) {
        AppLogger.w('Error al eliminar BD (puede no existir)', error: e);
      }
    }

    // Asegurar que la BD esté lista (Drift abre lazily en el primer query)
    try {
      await _databaseHelper.customSelect('SELECT 1').getSingle();
    } catch (e) {
      AppLogger.w('Error al abrir la base de datos. Intentando recrear...', error: e);
      try {
        await _databaseHelper.deleteDatabaseFile();
        await _databaseHelper.customSelect('SELECT 1').getSingle();
      } catch (e2) {
        AppLogger.e('Error crítico al inicializar la base de datos', error: e2);
        rethrow;
      }
    }

    _networkInfo = NetworkInfoImpl(InternetConnectionChecker.instance);
    _supabaseClient = Supabase.instance.client;
    _supabaseClientWrapper = SupabaseClientWrapperImpl(client: _supabaseClient);

    // Inicializar servicio de autenticación
    _authService = SupabaseAuthService(_supabaseClient);
    AppLogger.i('✅ [DI] AuthService inicializado');

    // Inicializar datasource de usuarios
    _usersRemoteDataSource = UsersRemoteDataSourceImpl(client: _supabaseClient);
    AppLogger.i('✅ [DI] UsersRemoteDataSource inicializado');

    // Inicializar repositorio de autenticación
    _authRepository = AuthRepositoryImpl(
      authService: _authService,
      usersDataSource: _usersRemoteDataSource,
    );
    AppLogger.i('✅ [DI] AuthRepository inicializado con UsersRemoteDataSource');

    // Inicializar casos de uso de autenticación
    _signInWithEmailUseCase = SignInWithEmailUseCase(
      authRepository: _authRepository,
    );
    _signUpWithEmailUseCase = SignUpWithEmailUseCase(
      authRepository: _authRepository,
    );
    _signInWithGoogleUseCase = SignInWithGoogleUseCase(
      authRepository: _authRepository,
    );
    _signOutUseCase = SignOutUseCase(
      authRepository: _authRepository,
      databaseHelper: _databaseHelper,
    );
    _getCurrentUserUseCase = GetCurrentUserUseCase(
      authRepository: _authRepository,
    );

    // 2. Inicializar datasources
    _remoteDataSource = HabitsRemoteDataSourceImpl(client: _supabaseClientWrapper);
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
    _saveHabitProgressUseCase = SaveHabitProgressUseCase(_habitRepository);

    _isInitialized = true;
  }

  // Getters para acceder a las dependencias
  HabitRepository get habitRepository => _habitRepository;
  AuthRepository get authRepository => _authRepository;
  AppDatabase get databaseHelper => _databaseHelper;
  NetworkInfo get networkInfo => _networkInfo;
  SyncService get syncService => _syncService;
  AuthService get authService => _authService;
  UsersRemoteDataSource get usersRemoteDataSource => _usersRemoteDataSource;

  // Getters para los casos de uso de Hábitos
  CreateHabitUseCase get createHabitUseCase => _createHabitUseCase;
  UpdateHabitUseCase get updateHabitUseCase => _updateHabitUseCase;
  DeleteHabitUseCase get deleteHabitUseCase => _deleteHabitUseCase;
  SaveHabitProgressUseCase get saveHabitProgressUseCase =>
      _saveHabitProgressUseCase;

  // Getters para los casos de uso de Autenticación
  SignInWithEmailUseCase get signInWithEmailUseCase => _signInWithEmailUseCase;
  SignUpWithEmailUseCase get signUpWithEmailUseCase => _signUpWithEmailUseCase;
  SignInWithGoogleUseCase get signInWithGoogleUseCase =>
      _signInWithGoogleUseCase;
  SignOutUseCase get signOutUseCase => _signOutUseCase;
  GetCurrentUserUseCase get getCurrentUserUseCase => _getCurrentUserUseCase;

  /// Verifica si el sistema de autenticación está correctamente inicializado
  bool get isAuthInitialized => _isInitialized;
}

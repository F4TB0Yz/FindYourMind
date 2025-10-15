import 'package:find_your_mind/core/config/database_helper.dart';
import 'package:find_your_mind/core/network/network_info.dart';
import 'package:find_your_mind/core/services/sync_service.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_local_datasource.dart';
import 'package:find_your_mind/features/habits/data/datasources/habits_remote_datasource.dart';
import 'package:find_your_mind/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  
  // Servicios
  late final SyncService _syncService;
  
  // Repositorio
  late final HabitRepository _habitRepository;

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

    // 2. Inicializar datasources
    _remoteDataSource = HabitsRemoteDataSourceImpl(client: _supabaseClient);
    _localDataSource = HabitsLocalDatasourceImpl(databaseHelper: _databaseHelper);

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

    _isInitialized = true;
  }

  // Getters para acceder a las dependencias
  HabitRepository get habitRepository => _habitRepository;
  DatabaseHelper get databaseHelper => _databaseHelper;
  NetworkInfo get networkInfo => _networkInfo;
  SyncService get syncService => _syncService;
}

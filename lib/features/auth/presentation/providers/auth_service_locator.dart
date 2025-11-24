import 'package:find_your_mind/core/services/auth_service.dart';
import 'package:find_your_mind/core/config/database_helper.dart';
import 'package:find_your_mind/features/auth/data/datasources/users_remote_datasource.dart';
import 'package:find_your_mind/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:find_your_mind/features/auth/domain/repositories/auth_repository.dart';
import 'package:find_your_mind/features/auth/domain/usecases/usecases.dart';

/// Service Locator para manejar la inyección de dependencias
/// Proporciona instancias únicas (singleton) de los casos de uso
class AuthServiceLocator {
  static final AuthServiceLocator _instance = AuthServiceLocator._internal();

  late AuthService _authService;
  late UsersRemoteDataSource _usersDataSource;
  late DatabaseHelper _databaseHelper;
  late AuthRepository _authRepository;
  late SignInWithEmailUseCase _signInWithEmailUseCase;
  late SignUpWithEmailUseCase _signUpWithEmailUseCase;
  late SignInWithGoogleUseCase _signInWithGoogleUseCase;
  late SignOutUseCase _signOutUseCase;
  late GetCurrentUserUseCase _getCurrentUserUseCase;

  factory AuthServiceLocator() {
    return _instance;
  }

  AuthServiceLocator._internal();

  /// Inicializa el localizador con el AuthService, UsersRemoteDataSource y DatabaseHelper
  /// Debe ser llamado en main() antes de usar cualquier caso de uso
  void setup(
    AuthService authService,
    UsersRemoteDataSource usersDataSource,
    DatabaseHelper databaseHelper,
  ) {
    _authService = authService;
    _usersDataSource = usersDataSource;
    _databaseHelper = databaseHelper;
    _authRepository = AuthRepositoryImpl(
      authService: _authService,
      usersDataSource: _usersDataSource,
    );
    _signInWithEmailUseCase = SignInWithEmailUseCase(authRepository: _authRepository);
    _signUpWithEmailUseCase = SignUpWithEmailUseCase(authRepository: _authRepository);
    _signInWithGoogleUseCase = SignInWithGoogleUseCase(authRepository: _authRepository);
    _signOutUseCase = SignOutUseCase(authRepository: _authRepository, databaseHelper: _databaseHelper);
    _getCurrentUserUseCase = GetCurrentUserUseCase(authRepository: _authRepository);
  }

  // Getters para acceder a los casos de uso
  SignInWithEmailUseCase get signInWithEmailUseCase => _signInWithEmailUseCase;
  SignUpWithEmailUseCase get signUpWithEmailUseCase => _signUpWithEmailUseCase;
  SignInWithGoogleUseCase get signInWithGoogleUseCase => _signInWithGoogleUseCase;
  SignOutUseCase get signOutUseCase => _signOutUseCase;
  GetCurrentUserUseCase get getCurrentUserUseCase => _getCurrentUserUseCase;
  AuthRepository get authRepository => _authRepository;
}

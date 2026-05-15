import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:find_your_mind/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:flutter/foundation.dart';

class ProfileProvider extends ChangeNotifier {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignOutUseCase _signOutUseCase;

  UserEntity? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserEntity? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProfileProvider({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SignOutUseCase signOutUseCase,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _signOutUseCase = signOutUseCase;

  Future<void> loadUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await _getCurrentUserUseCase();
    } catch (e) {
      _error = 'Error al cargar perfil: $e';
      AppLogger.e('Error loading user profile', error: e);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    final result = await _signOutUseCase();
    result.fold(
      (failure) {
        _error = failure.message;
        notifyListeners();
      },
      (_) {},
    );
  }
}

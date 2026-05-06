import 'dart:async';
import 'package:find_your_mind/core/utils/app_logger.dart';
import 'package:find_your_mind/core/config/dependency_injection.dart';
import 'package:find_your_mind/core/network/network_info.dart';
import 'package:find_your_mind/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:find_your_mind/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Provider centralizado para la gestión de sincronización
/// Maneja:
/// - Sincronización automática periódica
/// - Sincronización manual
/// - Estado de sincronización
/// - Contador de cambios pendientes
class SyncProvider extends ChangeNotifier {
  // Propiedades privadas
  bool _isSyncing = false;
  bool _disposed = false;
  int _pendingChangesCount = 0;
  DateTime? _lastSyncTime;
  String? _lastSyncError;

  // Constantes
  static const Duration _autoSyncInterval = Duration(minutes: 5);
  static const Duration _syncDelay = Duration(milliseconds: 800);
  static const Duration _refreshDelay = Duration(milliseconds: 500);
  static const Duration _initialPendingCountDelay = Duration(milliseconds: 1200);

  // Repositorio
  final HabitRepositoryImpl _repository = DependencyInjection().habitRepository as HabitRepositoryImpl;
  
  // Caso de uso de autenticación
  final GetCurrentUserUseCase _getCurrentUserUseCase = DependencyInjection().getCurrentUserUseCase;

  // Timer para sincronización automática
  Timer? _syncTimer;

  // Network info para listener de conectividad
  final NetworkInfo _networkInfo = DependencyInjection().networkInfo;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _wasDisconnected = false;

  // Callback para recargar datos después de la sincronización
  VoidCallback? _onSyncComplete;

  // Getters
  bool get isSyncing => _isSyncing;
  int get pendingChangesCount => _pendingChangesCount;
  DateTime? get lastSyncTime => _lastSyncTime;
  String? get lastSyncError => _lastSyncError;
  bool get hasError => _lastSyncError != null;

  SyncProvider() {
    _startAutoSync();
    _startConnectivityListener();
    Future<void>.delayed(_initialPendingCountDelay, () async {
      if (_disposed) return;
      await _updatePendingCount();
    });
  }

  /// Obtiene el ID del usuario autenticado
  /// Retorna el ID del usuario actual o null si no hay sesión
  Future<String?> _getUserId() async {
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null && user.id.isNotEmpty) {
        return user.id;
      }
      AppLogger.w('No hay usuario autenticado');
      return null;
    } catch (e) {
      AppLogger.e('Error al obtener usuario', error: e);
      return null;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  /// Registra un callback para ejecutar después de la sincronización
  void setOnSyncCompleteCallback(VoidCallback callback) {
    _onSyncComplete = callback;
  }

  /// Limpia el callback
  void clearOnSyncCompleteCallback() {
    _onSyncComplete = null;
  }

  /// Inicia la sincronización automática cada 5 minutos
  void _startAutoSync() {
    _syncTimer = Timer.periodic(_autoSyncInterval, (_) async {
      await _syncInBackground();
    });
  }

  /// Escucha cambios de conectividad y sincroniza al reconectar
  void _startConnectivityListener() {
    _connectivitySubscription = _networkInfo.onConnectivityChanged.listen(
      (isConnected) async {
        if (isConnected && _wasDisconnected) {
          await _syncInBackground();
        }
        _wasDisconnected = !isConnected;
      },
    );
  }

  /// Actualiza el contador de cambios pendientes
  Future<void> _updatePendingCount() async {
    try {
      _pendingChangesCount = await _repository.getPendingSyncCount();
      notifyListeners();
    } catch (e) {
      AppLogger.w('Error al actualizar contador pendiente', error: e);
    }
  }

  /// Sincroniza en segundo plano sin bloquear la UI
  Future<void> _syncInBackground() async {
    if (_isSyncing || _disposed) return;
    _isSyncing = true;
    _lastSyncError = null;
    notifyListeners();

    try {
      // Delay para asegurar que las operaciones de escritura anteriores terminen
      await Future.delayed(_syncDelay);

      final userId = await _getUserId();
      if (userId == null) return;
      
      final result = await _repository.syncWithRemote(userId);

      if (result.isFullSuccess || result.success > 0) {
        _lastSyncTime = DateTime.now();
        
        // Otro delay antes de refrescar
        await Future.delayed(_refreshDelay);

        // Actualizar contador de cambios pendientes
        await _updatePendingCount();

        // Ejecutar callback si existe (para recargar datos en HabitsProvider)
        _onSyncComplete?.call();
      }
    } catch (e) {
      // Sincronización silenciosa, no mostrar error al usuario
      AppLogger.d('Sincronización en segundo plano (no crítico)', error: e);
      _lastSyncError = e.toString();
    } finally {
      _isSyncing = false;
      if (!_disposed) notifyListeners();
    }
  }

  /// Sincronización manual (para botón de refresh)
  Future<bool> syncWithServer() async {
    if (_isSyncing) {
      AppLogger.w('Sincronización ya en progreso');
      return false;
    }

    try {
      _isSyncing = true;
      _lastSyncError = null;
      notifyListeners();

      final userId = await _getUserId();
      if (userId == null) {
        _isSyncing = false;
        notifyListeners();
        return false;
      }
      
      final result = await _repository.syncWithRemote(userId);

      if (result.isFullSuccess || result.success > 0) {
        _lastSyncTime = DateTime.now();
        
        // Actualizar contador de cambios pendientes
        await _updatePendingCount();

        // Ejecutar callback si existe (para recargar datos en HabitsProvider)
        _onSyncComplete?.call();
        
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.e('Error syncWithServer', error: e);
      _lastSyncError = e.toString();
      return false;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  /// Obtiene el número de cambios pendientes de sincronización
  Future<int> getPendingChangesCount() async {
    try {
      return await _repository.getPendingSyncCount();
    } catch (e) {
      AppLogger.e('Error getPendingChangesCount', error: e);
      return 0;
    }
  }

  /// Marca que hay cambios pendientes (llamar después de operaciones CRUD)
  void markPendingChanges() {
    _updatePendingCount();
  }

  /// Limpia el error de sincronización
  void clearError() {
    if (_lastSyncError != null) {
      _lastSyncError = null;
      notifyListeners();
    }
  }

  /// Resetea el estado de sincronización (llamar en logout)
  void resetSyncState() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _wasDisconnected = false;
    _isSyncing = false;
    _pendingChangesCount = 0;
    _lastSyncTime = null;
    _lastSyncError = null;
    _onSyncComplete = null;
    notifyListeners();
    AppLogger.i('🧹 [SYNC_PROVIDER] Estado de sincronización reseteado');
  }
}
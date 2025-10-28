import 'dart:async';
import 'package:find_your_mind/core/config/dependency_injection.dart';
import 'package:find_your_mind/core/constants/string_constants.dart';
import 'package:find_your_mind/features/habits/data/repositories/habit_repository_impl.dart';
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
  static const Duration _autoSyncInterval = Duration(minutes: 100);
  static const Duration _syncDelay = Duration(milliseconds: 800);
  static const Duration _refreshDelay = Duration(milliseconds: 500);

  // Repositorio
  final HabitRepositoryImpl _repository = DependencyInjection().habitRepository as HabitRepositoryImpl;

  // Timer para sincronización automática
  Timer? _syncTimer;

  // UUID del usuario de Supabase
  final String _userId = AppConstants.currentUserId;

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
    _updatePendingCount();
  }

  @override
  void dispose() {
    _disposed = true;
    _syncTimer?.cancel();
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

  /// Actualiza el contador de cambios pendientes
  Future<void> _updatePendingCount() async {
    try {
      _pendingChangesCount = await _repository.getPendingSyncCount();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('⚠️ Error al actualizar contador pendiente: $e');
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

      final result = await _repository.syncWithRemote(_userId);

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
      if (kDebugMode) print('🔄 Sincronización en segundo plano (no crítico): $e');
      _lastSyncError = e.toString();
    } finally {
      _isSyncing = false;
      if (!_disposed) notifyListeners();
    }
  }

  /// Sincronización manual (para botón de refresh)
  Future<bool> syncWithServer() async {
    if (_isSyncing) {
      if (kDebugMode) print('⚠️ Sincronización ya en progreso');
      return false;
    }

    try {
      _isSyncing = true;
      _lastSyncError = null;
      notifyListeners();

      final result = await _repository.syncWithRemote(_userId);

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
      if (kDebugMode) print('❌ Error syncWithServer: $e');
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
      if (kDebugMode) print('❌ Error getPendingChangesCount: $e');
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
}
import 'dart:async';
import 'package:find_your_mind/core/config/dependency_injection.dart';
import 'package:find_your_mind/core/constants/string_constants.dart';
import 'package:find_your_mind/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:flutter/foundation.dart';

class HabitsProvider extends ChangeNotifier {
  String _titleScreen = AppStrings.habitsTitle;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final List<HabitEntity> _habits = [];
  static const int _pageSize = 10;
  
  // Repositorio con lógica offline-first
  final HabitRepository _repository = DependencyInjection().habitRepository;
  
  // Timer para sincronización automática
  Timer? _syncTimer;
  
  // UUID del usuario de Supabase
  final String _userId = 'c2fa89e9-ab8e-4592-b14e-223d7d7aa55d';

  String get titleScreen => _titleScreen;
  bool get isEditing => _isEditing;
  List<HabitEntity> get habits => _habits;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  HabitsProvider() {
    _startAutoSync();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  /// Inicia la sincronización automática cada 5 minutos
  void _startAutoSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) async {
      await _syncInBackground();
    });
  }

  /// Sincroniza en segundo plano sin bloquear la UI
  Future<void> _syncInBackground() async {
    try {
      // Delay para asegurar que las operaciones de escritura anteriores terminen
      await Future.delayed(const Duration(milliseconds: 800));
      
      final repo = _repository as HabitRepositoryImpl;
      await repo.syncWithRemote(_userId);
      
      // Otro delay antes de refrescar
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Recargar datos actualizados
      await _refreshHabitsFromLocal();
    } catch (e) {
      // Sincronización silenciosa, no mostrar error al usuario
      if (kDebugMode) print('🔄 Sincronización en segundo plano (no crítico): $e');
    }
  }

  /// Recarga hábitos desde SQLite sin mostrar loading
  Future<void> _refreshHabitsFromLocal() async {
    try {
      print('🔄 [PROVIDER] Refrescando desde SQLite...');
      final updatedHabits = await _repository.getHabitsByEmail(_userId);
      _habits.clear();
      _habits.addAll(updatedHabits);
      notifyListeners();
      print('✅ [PROVIDER] Refrescado exitoso - ${updatedHabits.length} hábitos');
    } catch (e) {
      // Error no crítico - los datos ya están cargados en memoria
      if (kDebugMode) print('⚠️ Error al refrescar desde SQLite (datos ya en memoria): $e');
    }
  }

  void changeTitle(String newTitle) {
    if (_titleScreen == newTitle) return;
    _titleScreen = newTitle;
    notifyListeners();
  }

  void resetTitle() {
    if ( _titleScreen != AppStrings.habitsTitle) {
      _titleScreen = AppStrings.habitsTitle;
    }
  }

  void changeIsEditing(bool editing) {
    if (_isEditing != editing) _isEditing = editing;
    notifyListeners();
  }

  void addHabit(HabitEntity habit) {
    _habits.add(habit);
    notifyListeners();
  }

  /// Carga hábitos desde SQLite (instantáneo) y sincroniza en segundo plano
  Future<void> loadHabits() async {
    if (_isLoading) return;
    
    print('🚀 [PROVIDER] Iniciando loadHabits()...');
    _isLoading = true;
    _currentPage = 0;
    _habits.clear();
    notifyListeners();

    try {
      print('📞 [PROVIDER] Llamando a repository.getHabitsByEmailPaginated...');
      // Cargar desde SQLite (offline-first, instantáneo)
      final List<HabitEntity> habits = await _repository.getHabitsByEmailPaginated(
        email: _userId,
        limit: _pageSize,
        offset: 0,
      );
      
      print('✅ [PROVIDER] Recibidos ${habits.length} hábitos del repository');
      _habits.addAll(habits);
      _hasMore = habits.length == _pageSize;
      _currentPage = 1;
      
      // Sincronización en segundo plano (no bloquea la UI)
      _syncInBackground();
    } catch (e) {
      print('❌ [PROVIDER] Error loadHabits: $e');
      if (kDebugMode) print('❌ Error loadHabits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
      print('🏁 [PROVIDER] loadHabits() finalizado - ${_habits.length} hábitos en memoria');
    }
  }

  /// Carga más hábitos con paginación
  Future<void> loadMoreHabits() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final List<HabitEntity> newHabits = await _repository.getHabitsByEmailPaginated(
        email: _userId,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );
      
      _habits.addAll(newHabits);
      _hasMore = newHabits.length == _pageSize;
      _currentPage++;
    } catch (e) {
      if (kDebugMode) print('❌ Error loadMoreHabits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza el progreso de un hábito (funciona offline)
  Future<void> updateHabitProgress(HabitProgress todayProgress) async {
    try {
      // Actualizar en el repositorio (SQLite + sync automático)
      await _repository.updateHabitProgress(
        todayProgress.habitId,
        todayProgress.id,
        todayProgress.dailyCounter,
      );

      // Actualizar el estado local
      final habitIndex = _habits.indexWhere(
        (habit) => habit.id == todayProgress.habitId
      );

      if (habitIndex == -1) return;

      final progressIndex = _habits[habitIndex]
        .progress
        .indexWhere((p) => p.id == todayProgress.id);

      if (progressIndex == -1) {
        // Agregar nuevo progreso
        final updatedHabit = _habits[habitIndex]
          .copyWith(progress: [..._habits[habitIndex].progress, todayProgress]);
        _habits[habitIndex] = updatedHabit;
      } else {
        // Actualizar progreso existente
        final updatedProgress = [..._habits[habitIndex].progress];
        updatedProgress[progressIndex] = todayProgress;

        final updatedHabit = _habits[habitIndex]
          .copyWith(progress: updatedProgress);
        _habits[habitIndex] = updatedHabit;
      }
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Error updateHabitProgress: $e');
    }
  }

  /// Actualiza un hábito existente (funciona offline)
  Future<bool> updateHabit(HabitEntity updatedHabit) async {
    try {
      // Actualizar en el repositorio (SQLite + sync automático)
      await _repository.updateHabit(updatedHabit);
      
      // Actualizar el estado local
      final habitIndex = _habits.indexWhere((h) => h.id == updatedHabit.id);
      if (habitIndex != -1) {
        _habits[habitIndex] = updatedHabit;
        notifyListeners();
      }
      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error updateHabit: $e');
      return false;
    }
  }

  /// Elimina un hábito (funciona offline)
  Future<void> deleteHabit(String habitId) async {
    try {
      // Eliminar del repositorio (SQLite + sync automático)
      await _repository.deleteHabit(habitId);
      
      // Actualizar el estado local
      _habits.removeWhere((h) => h.id == habitId);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('❌ Error deleteHabit: $e');
    }
  }

  /// Sincronización manual (para botón de refresh)
  Future<bool> syncWithServer() async {
    try {
      if (_repository is! HabitRepositoryImpl) return false;
      
      final result = await (_repository as dynamic).syncWithRemote(_userId);
      
      if (result.isFullSuccess || result.success > 0) {
        // Recargar datos actualizados
        await loadHabits();
        return true;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) print('❌ Error syncWithServer: $e');
      return false;
    }
  }

  /// Obtiene el número de cambios pendientes de sincronización
  Future<int> getPendingChangesCount() async {
    try {
      if (_repository is! HabitRepositoryImpl) return 0;
      return await (_repository as dynamic).getPendingSyncCount();
    } catch (e) {
      if (kDebugMode) print('❌ Error getPendingChangesCount: $e');
      return 0;
    }
  }
}

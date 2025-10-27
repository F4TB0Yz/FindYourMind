import 'package:find_your_mind/core/config/dependency_injection.dart';
import 'package:find_your_mind/core/constants/string_constants.dart';
import 'package:find_your_mind/core/services/sync_service.dart';
import 'package:find_your_mind/core/utils/date_utils.dart';
import 'package:find_your_mind/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habits_screen.dart';
import 'package:find_your_mind/shared/domain/screen_type.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class HabitsProvider extends ChangeNotifier {
  // Propiedades privadas
  String _titleScreen = AppStrings.habitsTitle;
  String? _lastError;
  DateTime? _lastErrorTime;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final List<HabitEntity> _habits = [];
  
  // Constantes
  static const int _pageSize = 10;
  
  // Repositorio con lógica offline-first
  final HabitRepositoryImpl _repository = DependencyInjection().habitRepository as HabitRepositoryImpl;
  
  // UUID del usuario de Supabase
  final String _userId = 'c2fa89e9-ab8e-4592-b14e-223d7d7aa55d';

  // Constructor: Registrar callback para actualizaciones de ID
  HabitsProvider() {
    // Registrar callback para recibir notificaciones cuando se actualice un ID
    SyncService.onHabitIdUpdated = updateHabitIdSilently;
  }

  // Getters
  String get titleScreen => _titleScreen;
  String? get lastError => _lastError;
  DateTime? get lastErrorTime => _lastErrorTime;
  bool get isEditing => _isEditing;
  List<HabitEntity> get habits => List.unmodifiable(_habits); // Inmutable para evitar modificaciones externas
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get hasError => _lastError != null;


  /// Establece un error y notifica a los listeners
  void _setError(String error) {
    _lastError = error;
    _lastErrorTime = DateTime.now();
    notifyListeners();
    if (kDebugMode) print('❌ Error: $error');
  }

  /// Limpia el error actual
  void clearError() {
    if (_lastError != null) {
      _lastError = null;
      _lastErrorTime = null;
      notifyListeners();
    }
  }

  /// Recarga hábitos desde SQLite sin mostrar loading (llamado por SyncProvider)
  Future<void> refreshHabitsFromLocal() async {
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
    if (_titleScreen != AppStrings.habitsTitle) {
      _titleScreen = AppStrings.habitsTitle;
      notifyListeners();
    }
  }

  void changeIsEditing(bool editing) {
    if (_isEditing == editing) return;
    _isEditing = editing;
    notifyListeners();
  }

  /// Carga hábitos desde SQLite (instantáneo) y sincroniza en segundo plano
  Future<void> loadHabits() async {
    if (kDebugMode) print('🚀 [PROVIDER] Iniciando loadHabits()...');
    _currentPage = 0;
    _habits.clear();
    clearError(); // Limpiar errores previos
    notifyListeners();

    try {
      if (kDebugMode) print('📞 [PROVIDER] Llamando a repository.getHabitsByEmailPaginated...');
      // Cargar desde SQLite (offline-first, instantáneo) - NO mostramos loading
      final List<HabitEntity> habits = await _repository.getHabitsByEmailPaginated(
        email: _userId,
        limit: _pageSize,
        offset: 0,
      );
      
      if (kDebugMode) print('✅ [PROVIDER] Recibidos ${habits.length} hábitos del repository');
      _habits.addAll(habits);
      _hasMore = habits.length == _pageSize;
      _currentPage = 1;
      notifyListeners();
      
    } catch (e) {
      if (kDebugMode) print('❌ [PROVIDER] Error loadHabits: $e');
      _setError('Error al cargar los hábitos: ${e.toString()}');
      notifyListeners();
    }
    
    if (kDebugMode) print('🏁 [PROVIDER] loadHabits() finalizado - ${_habits.length} hábitos en memoria');
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
      _setError('Error al cargar más hábitos: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualiza el progreso de un hábito (funciona offline)
  Future<bool> updateHabitProgress(HabitProgress todayProgress) async {
    try {
      // Actualizar en el repositorio (SQLite + sync automático)
      final result = await _repository.updateHabitProgress(
        todayProgress.habitId,
        todayProgress.id,
        todayProgress.dailyCounter,
      );

      return result.fold(
        (failure) {
          if (kDebugMode) print('❌ Error al actualizar progreso: ${failure.message}');
          _setError('Error al actualizar progreso: ${failure.message}');
          return false;
        },
        (_) {
          // Actualizar el estado local
          final habitIndex = _habits.indexWhere(
            (habit) => habit.id == todayProgress.habitId
          );

          if (habitIndex == -1) {
            if (kDebugMode) print('⚠️ Hábito no encontrado en la lista local');
            return true;
          }

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
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error updateHabitProgress: $e');
      _setError('Error inesperado al actualizar progreso: ${e.toString()}');
      return false;
    }
  }

  /// Actualiza el progreso de un hábito SOLO en la UI (sin tocar el repositorio)
  /// Este método es para actualizaciones optimistas instantáneas
  void updateHabitProgressOptimistic(HabitProgress todayProgress) {
    final habitIndex = _habits.indexWhere(
      (habit) => habit.id == todayProgress.habitId
    );

    if (habitIndex == -1) {
      if (kDebugMode) print('⚠️ Hábito no encontrado en la lista local');
      return;
    }

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
  }

  /// Actualiza un hábito existente (funciona offline)
  Future<bool> updateHabit(HabitEntity updatedHabit) async {
    try {
      // Actualizar en el repositorio (SQLite + sync automático)
      final result = await _repository.updateHabit(updatedHabit);
      
      return result.fold(
        (failure) {
          if (kDebugMode) print('❌ Error al actualizar hábito: ${failure.message}');
          _setError('Error al actualizar hábito: ${failure.message}');
          return false;
        },
        (_) {
          // Actualizar el estado local
          final habitIndex = _habits.indexWhere((h) => h.id == updatedHabit.id);
          if (habitIndex != -1) {
            _habits[habitIndex] = updatedHabit;
            notifyListeners();
          }
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error updateHabit: $e');
      _setError('Error inesperado al actualizar hábito: ${e.toString()}');
      return false;
    }
  }

  /// Crea un nuevo hábito (funciona offline)
  /// 🚀 ACTUALIZACIÓN OPTIMISTA: Actualiza la UI UNA SOLA VEZ
  Future<String?> createHabit(HabitEntity habit) async {
    try {
      // 🚀 1. ACTUALIZACIÓN OPTIMISTA: Guardar en estado local primero
      // Esto actualiza la UI inmediatamente sin esperar a la base de datos
      final String tempId = const Uuid().v4(); // ID temporal
      final habitWithTempId = habit.copyWith(id: tempId);
      
      _habits.insert(0, habitWithTempId);
      notifyListeners(); // ✅ ÚNICA actualización de UI
      
      if (kDebugMode) print('✅ Hábito agregado optimistamente a la UI');

      // 💾 2. Guardar en el repositorio en segundo plano (SQLite + sync automático)
      final result = await _repository.createHabit(habit);
      
      return result.fold(
        (failure) {
          if (kDebugMode) print('❌ Error al crear hábito: ${failure.message}');
          
          // Revertir cambio optimista si falla
          _habits.removeWhere((h) => h.id == tempId);
          notifyListeners();
          
          return null;
        },
        (habitId) {
          if (habitId == null) {
            if (kDebugMode) print('⚠️ HabitId es null después de crear');
            
            // Revertir cambio optimista si falla
            _habits.removeWhere((h) => h.id == tempId);
            notifyListeners();
            
            return null;
          }
          
          // ✅ 3. Actualizar el ID del hábito en la lista
          final habitIndex = _habits.indexWhere((h) => h.id == tempId);
          if (habitIndex != -1) {
            _habits[habitIndex] = habit.copyWith(id: habitId);
            notifyListeners(); // ✅ Actualizar UI con ID real
            if (kDebugMode) print('🔄 ID local actualizado: $tempId → $habitId');
          }
          
          if (kDebugMode) print('✅ Hábito guardado con ID real: $habitId');
          
          return habitId;
        },
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error createHabit: $e');
      _setError('Error inesperado al crear hábito: ${e.toString()}');
      // Revertir cambio local
      _habits.removeWhere((h) => h.id == habit.id);
      notifyListeners();
      return null;
    }
  }

  /// Actualiza silenciosamente el ID de un hábito cuando llega el ID de Supabase
  /// Este método es llamado por el repositorio después de sincronizar con Supabase
  /// NO actualiza la UI (no llama notifyListeners) para evitar re-renders innecesarios
  void updateHabitIdSilently(String oldId, String newId) {
    if (oldId == newId) return;
    
    final index = _habits.indexWhere((h) => h.id == oldId);
    if (index != -1) {
      final habit = _habits[index];
      _habits[index] = habit.copyWith(id: newId);
      
      if (kDebugMode) print('🔄 ID del hábito actualizado en la app: $oldId → $newId');
      
      // ✅ Notificar para actualizar la UI inmediatamente
      notifyListeners();
    } else {
      if (kDebugMode) print('⚠️ No se encontró hábito con ID $oldId para actualizar');
    }
  }

  /// Crea un nuevo registro de progreso para un hábito
  Future<String?> createHabitProgress(
    String habitId,
    int dailyGoal,
  ) async {
    try {
      final String todayString = DateInfoUtils.todayString();

      // 🔍 Buscar el hábito (puede tener ID temporal o real)
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      
      if (habitIndex == -1) {
        if (kDebugMode) print('⚠️ Hábito con ID $habitId no encontrado');
        return null;
      }

      // 💾 Crear el progreso en el repositorio primero
      final String? progressId = await _repository.createHabitProgress(
        habitId: habitId,
        date: todayString,
        dailyCounter: 0,
        dailyGoal: dailyGoal,
      );

      if (progressId == null) {
        if (kDebugMode) print('❌ Error: progressId es null');
        return null;
      }

      // ✅ Agregar el progreso al hábito en la lista
      final HabitProgress newProgress = HabitProgress(
        id: progressId,
        habitId: habitId,
        date: todayString,
        dailyGoal: dailyGoal,
        dailyCounter: 0,
      );
      
      _habits[habitIndex].progress.add(newProgress);
      notifyListeners();

      if (kDebugMode) print('✅ Progreso creado con ID: $progressId');
      return progressId;
    } catch (e) {
      if (kDebugMode) print('❌ Error createHabitProgress: $e');
      return null;
    }
  }

  /// Elimina un hábito (funciona offline)
  Future<bool> deleteHabit(String habitId) async {
    try {
      // Eliminar del repositorio (SQLite + sync automático)
      final result = await _repository.deleteHabit(habitId);
      
      return result.fold(
        (failure) {
          if (kDebugMode) print('❌ Error al eliminar hábito: ${failure.message}');
          _setError('Error al eliminar hábito: ${failure.message}');
          return false;
        },
        (_) {
          // Actualizar el estado local
          _habits.removeWhere((h) => h.id == habitId);
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error deleteHabit: $e');
      _setError('Error inesperado al eliminar hábito: ${e.toString()}');
      return false;
    }
  }
}

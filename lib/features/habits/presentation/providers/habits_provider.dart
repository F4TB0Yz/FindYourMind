import 'package:find_your_mind/core/constants/string_constants.dart';
import 'package:find_your_mind/core/utils/date_utils.dart';
import 'package:find_your_mind/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/usecases/create_habit.dart';
import 'package:find_your_mind/features/habits/domain/usecases/decrement_habit_progress_usecase.dart';
import 'package:find_your_mind/features/habits/domain/usecases/delete_habit_usecase.dart';
import 'package:find_your_mind/features/habits/domain/usecases/increment_habit_progress_usecase.dart';
import 'package:find_your_mind/features/habits/domain/usecases/update_habit_usecase.dart';
import 'package:find_your_mind/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:find_your_mind/shared/presentation/providers/sync_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class HabitsProvider extends ChangeNotifier {
  // Casos de uso
  final CreateHabitUseCase _createHabitUseCase;
  final UpdateHabitUseCase _updateHabitUseCase;
  final DeleteHabitUseCase _deleteHabitUseCase;
  final IncrementHabitProgressUseCase _incrementHabitProgressUseCase;
  final DecrementHabitProgressUseCase _decrementHabitProgressUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  
  // Repositorio (para métodos que aún no tienen caso de uso)
  final HabitRepositoryImpl _repository;
  
  // Propiedades privadas
  String _titleScreen = AppStrings.habitsTitle;
  String? _lastError;
  DateTime? _lastErrorTime;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final List<HabitEntity> _habits = [];
  
  // Mapa para evitar condiciones de carrera en SQLite al golpear repetidamente +/-
  final Map<String, Future<void>> _ongoingDbOperations = {};
  
  // Referencia al SyncProvider para notificar cambios pendientes
  SyncProvider? _syncProvider;
  
  // Constantes
  static const int _pageSize = 10;

  // Constructor con inyección de dependencias
  HabitsProvider({
    required CreateHabitUseCase createHabitUseCase,
    required UpdateHabitUseCase updateHabitUseCase,
    required DeleteHabitUseCase deleteHabitUseCase,
    required IncrementHabitProgressUseCase incrementHabitProgressUseCase,
    required DecrementHabitProgressUseCase decrementHabitProgressUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required HabitRepositoryImpl repository,
  })  : _createHabitUseCase = createHabitUseCase,
        _updateHabitUseCase = updateHabitUseCase,
        _deleteHabitUseCase = deleteHabitUseCase,
        _incrementHabitProgressUseCase = incrementHabitProgressUseCase,
        _decrementHabitProgressUseCase = decrementHabitProgressUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        _repository = repository;

  // Getters
  String get titleScreen => _titleScreen;
  String? get lastError => _lastError;
  DateTime? get lastErrorTime => _lastErrorTime;
  bool get isEditing => _isEditing;
  List<HabitEntity> get habits => List.unmodifiable(_habits); // Inmutable para evitar modificaciones externas
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get hasError => _lastError != null;

  /// Obtiene el ID del usuario autenticado
  /// Retorna el ID del usuario actual o un valor por defecto si no hay sesión
  Future<String> getUserId() async {
    try {
      final user = await _getCurrentUserUseCase();
      if (user != null && user.id.isNotEmpty) {
        return user.id;
      }
      // Fallback al ID hardcodeado si no hay usuario autenticado
      if (kDebugMode) print('⚠️ No hay usuario autenticado, usando ID por defecto');
      return AppConstants.currentUserId;
    } catch (e) {
      if (kDebugMode) print('❌ Error al obtener usuario: $e');
      return AppConstants.currentUserId;
    }
  }

  /// Obtiene el contador de progreso del día actual para un hábito específico
  /// Retorna 0 si no hay progreso para hoy
  int getTodayCount(String habitId) {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return 0;

    final String todayString = DateInfoUtils.todayString();
    final todayProgress = _habits[habitIndex].progress.firstWhere(
      (progress) => progress.date == todayString,
      orElse: () => HabitProgress(
        id: '',
        habitId: habitId,
        date: todayString,
        dailyGoal: 0,
        dailyCounter: 0,
      ),
    );

    return todayProgress.dailyCounter;
  }

  /// Verifica si un hábito puede ser incrementado (no ha alcanzado la meta diaria)
  bool canIncrement(String habitId) {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return false;

    final currentCount = getTodayCount(habitId);
    final dailyGoal = _habits[habitIndex].dailyGoal;

    return currentCount < dailyGoal;
  }

  /// Verifica si un hábito puede ser decrementado (contador mayor a 0)
  bool canDecrement(String habitId) {
    final currentCount = getTodayCount(habitId);
    return currentCount > 0;
  }

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
      if (kDebugMode) print('🔄 [PROVIDER] Refrescando desde SQLite...');
      final userId = await getUserId();
      final updatedHabits = await _repository.getHabitsByEmail(userId);
      _habits.clear();
      
      // Agregar hábitos verificando duplicados (por si acaso)
      for (final habit in updatedHabits) {
        if (!_habits.any((h) => h.id == habit.id)) {
          _habits.add(habit);
        }
      }
      
      notifyListeners();
      if (kDebugMode) print('✅ [PROVIDER] Refrescado exitoso - ${_habits.length} hábitos');
    } catch (e) {
      // Error no crítico - los datos ya están cargados en memoria
      if (kDebugMode) print('⚠️ Error al refrescar desde SQLite (datos ya en memoria): $e');
    }
  }

  /// Establece la referencia al SyncProvider para notificar cambios
  void setSyncProvider(SyncProvider syncProvider) {
    _syncProvider = syncProvider;
  }

  /// Notifica al SyncProvider que hay cambios pendientes
  void _notifyPendingChanges() {
    _syncProvider?.markPendingChanges();
  }

  /// Limpia todos los hábitos y progreso en memoria (llamar en logout)
  void clearAllData() {
    _habits.clear();
    notifyListeners();
    if (kDebugMode) print('🧹 [PROVIDER] Memoria limpiada - hábitos eliminados');
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
    _isLoading = true;
    clearError(); // Limpiar errores previos
    notifyListeners();

    try {
      if (kDebugMode) print('📞 [PROVIDER] Llamando a repository.getHabitsByEmailPaginated...');
      final userId = await getUserId();
      // Cargar desde SQLite (offline-first, instantáneo)
      final List<HabitEntity> habits = await _repository.getHabitsByEmailPaginated(
        email: userId,
        limit: _pageSize,
        offset: 0,
      );
      
      if (kDebugMode) print('✅ [PROVIDER] Recibidos ${habits.length} hábitos del repository');
      
      // Agregar solo hábitos que no existan ya (prevenir duplicados)
      for (final habit in habits) {
        if (!_habits.any((h) => h.id == habit.id)) {
          _habits.add(habit);
        } else {
          if (kDebugMode) print('⚠️ [PROVIDER] Hábito duplicado detectado y omitido: ${habit.id}');
        }
      }
      
      _hasMore = habits.length == _pageSize;
      _currentPage = 1;
      
    } catch (e) {
      if (kDebugMode) print('❌ [PROVIDER] Error loadHabits: $e');
      _setError('Error al cargar los hábitos: ${e.toString()}');
    } finally {
      _isLoading = false;
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
      final userId = await getUserId();
      final List<HabitEntity> newHabits = await _repository.getHabitsByEmailPaginated(
        email: userId,
        limit: _pageSize,
        offset: _currentPage * _pageSize,
      );
      
      // Agregar solo hábitos que no existan ya (prevenir duplicados)
      for (final habit in newHabits) {
        if (!_habits.any((h) => h.id == habit.id)) {
          _habits.add(habit);
        } else {
          if (kDebugMode) print('⚠️ [PROVIDER] Hábito duplicado en loadMoreHabits: ${habit.id}');
        }
      }
      
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

  /// Encola una operación de base de datos para que se ejecuten secuencialmente
  /// Esto previene Race Conditions (ej: un UPDATE de -1 llegando antes que el INSERT de +1)
  void _queueDbOperation(String habitId, Future<void> Function() operation) {
    final previousOperation = _ongoingDbOperations[habitId] ?? Future.value();
    
    final newOperation = previousOperation.then((_) => operation());
    _ongoingDbOperations[habitId] = newOperation;
    
    newOperation.whenComplete(() {
      if (_ongoingDbOperations[habitId] == newOperation) {
        _ongoingDbOperations.remove(habitId);
      }
    });
  }

  /// Incrementa el contador de progreso del día actual con actualización optimista
  /// Permite múltiples clics rápidos para registrar varias completaciones
  Future<bool> incrementHabitProgress(String habitId) async {
    return _executeIncrementProgress(habitId);
  }

  /// Método interno que ejecuta el incremento
  /// Separa la lógica de negocio (caso de uso) de la actualización optimista (UI)
  Future<bool> _executeIncrementProgress(String habitId) async {
    try {
      // 1. Validar que el hábito existe en la lista local
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) {
        if (kDebugMode) print('⚠️ Hábito no encontrado: $habitId');
        return false;
      }

      final habit = _habits[habitIndex];
      final String todayString = DateInfoUtils.todayString();
      
      // 2. Buscar progreso de hoy EN EL HÁBITO ACTUALIZADO
      final todayIndex = habit.progress.indexWhere(
        (progress) => progress.date == todayString,
      );

      HabitProgress optimisticProgress;
      bool isNewProgress = false;
      HabitProgress? existingTodayProgress;

      if (todayIndex == -1) {
        // Crear nuevo progreso optimista para la UI
        final String progressId = const Uuid().v4();
        optimisticProgress = HabitProgress(
          id: progressId,
          habitId: habitId,
          date: todayString,
          dailyGoal: habit.dailyGoal,
          dailyCounter: 1,
        );
        isNewProgress = true;
        
        if (kDebugMode) {
          print('🆕 Creando nuevo progreso optimista: $progressId');
        }
      } else {
        // Validar si ya se alcanzó la meta
        existingTodayProgress = habit.progress[todayIndex];
        if (existingTodayProgress.dailyCounter >= habit.dailyGoal) {
          if (kDebugMode) print('⚠️ Meta diaria ya alcanzada');
          return false;
        }
        
        // Incrementar contador optimistamente
        optimisticProgress = existingTodayProgress.copyWith(
          dailyCounter: existingTodayProgress.dailyCounter + 1,
        );
        
        if (kDebugMode) {
          print('➕ Incrementando progreso existente: ${existingTodayProgress.id} (${existingTodayProgress.dailyCounter} → ${optimisticProgress.dailyCounter})');
        }
      }

      // 🚀 ACTUALIZACIÓN OPTIMISTA INMEDIATA en la UI (NO bloqueante)
      updateHabitProgressOptimistic(optimisticProgress);

      // 💾 Ejecutar caso de uso en segundo plano (SECUENCIALMENTE ENCOLADO)
      _queueDbOperation(habitId, () async {
        // IMPORTANTE: NO podemos usar simplemente el currentHabit de la lista 
        // porque ya tiene el cambio optimista aplicado, lo que confunde las validaciones
        // del UseCase. Debemos usar el 'habit' capturado (que tiene el contador anterior),
        // PERO parchearle el UUID real más reciente en caso de que alguna operación
        // asíncrona lo haya cambiado por un UUID proveniente de base de datos.
        final currentHabitIndex = _habits.indexWhere((h) => h.id == habitId);
        if (currentHabitIndex == -1) return;
        
        final latestHabit = _habits[currentHabitIndex];
        final trueProgressIndex = latestHabit.progress.indexWhere((p) => p.date == todayString);
        String trueId = optimisticProgress.id;
        if (trueProgressIndex != -1) {
          trueId = latestHabit.progress[trueProgressIndex].id;
        }

        HabitEntity fixedHabit = habit;
        final fixedProgressIndex = fixedHabit.progress.indexWhere((p) => p.date == todayString);
        if (fixedProgressIndex != -1) {
          final fixedProgressList = [...fixedHabit.progress];
          fixedProgressList[fixedProgressIndex] = fixedProgressList[fixedProgressIndex].copyWith(id: trueId);
          fixedHabit = fixedHabit.copyWith(progress: fixedProgressList);
        }

        final result = await _incrementHabitProgressUseCase.execute(habit: fixedHabit);
        
        result.fold(
          (failure) {
            if (kDebugMode) print('❌ Error al incrementar: ${failure.message}');
            
            // ⚠️ NO revertir si el error es "Ya se alcanzó la meta" (ValidationFailure)
            final isValidationError = failure.message.contains('Ya se alcanzó la meta');
            
            if (!isValidationError) {
              // Revertir cambio optimista
              if (isNewProgress) {
                final idx = _habits.indexWhere((h) => h.id == habitId);
                if (idx != -1) {
                  _habits[idx].progress.removeWhere((p) => p.id == optimisticProgress.id);
                  notifyListeners();
                }
              } else {
                if (existingTodayProgress != null) {
                  updateHabitProgressOptimistic(existingTodayProgress);
                }
              }
            }
          },
          (updatedProgress) {
            if (kDebugMode) print('✅ Progreso guardado y sincronizado: ${updatedProgress.dailyCounter}');
            updateHabitProgressOptimistic(updatedProgress);
            _notifyPendingChanges();
          },
        );
      });

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error inesperado: $e');
      return false;
    }
  }

  /// Decrementa el contador de un hábito específico con actualización optimista
  Future<bool> decrementHabitProgress(String habitId) async {
    return _executeDecrementProgress(habitId);
  }

  /// Método interno que ejecuta el decremento
  /// Separa la lógica de negocio (caso de uso) de la actualización optimista (UI)
  Future<bool> _executeDecrementProgress(String habitId) async {
    try {
      // 1. Validar que el hábito existe en la lista local
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) {
        if (kDebugMode) print('⚠️ Hábito no encontrado: $habitId');
        return false;
      }

      final habit = _habits[habitIndex];
      final String todayString = DateInfoUtils.todayString();
      
      // 2. Buscar progreso de hoy
      final todayIndex = habit.progress.indexWhere(
        (progress) => progress.date == todayString,
      );

      if (todayIndex == -1) {
        if (kDebugMode) print('⚠️ No hay progreso para hoy');
        return false;
      }

      final todayProgress = habit.progress[todayIndex];

      if (todayProgress.dailyCounter <= 0) {
        if (kDebugMode) print('⚠️ El contador ya está en 0');
        return false;
      }

      // Decrementar contador optimistamente
      final optimisticProgress = todayProgress.copyWith(
        dailyCounter: todayProgress.dailyCounter - 1,
      );

      // 🚀 ACTUALIZACIÓN OPTIMISTA INMEDIATA en la UI (NO bloqueante)
      updateHabitProgressOptimistic(optimisticProgress);

      // 💾 Ejecutar caso de uso en segundo plano (SECUENCIALMENTE ENCOLADO)
      _queueDbOperation(habitId, () async {
        // IMPORTANTE: Al igual que en increment, usamos el hábito capturado
        // pero inyectamos el UUID más reciente conocido para no causar "Progreso no encontrado"
        final currentHabitIndex = _habits.indexWhere((h) => h.id == habitId);
        if (currentHabitIndex == -1) return;
        
        final latestHabit = _habits[currentHabitIndex];
        final trueProgressIndex = latestHabit.progress.indexWhere((p) => p.date == todayString);
        String trueId = optimisticProgress.id;
        if (trueProgressIndex != -1) {
          trueId = latestHabit.progress[trueProgressIndex].id;
        }

        HabitEntity fixedHabit = habit;
        final fixedProgressIndex = fixedHabit.progress.indexWhere((p) => p.date == todayString);
        if (fixedProgressIndex != -1) {
          final fixedProgressList = [...fixedHabit.progress];
          fixedProgressList[fixedProgressIndex] = fixedProgressList[fixedProgressIndex].copyWith(id: trueId);
          fixedHabit = fixedHabit.copyWith(progress: fixedProgressList);
        }

        final result = await _decrementHabitProgressUseCase.execute(habit: fixedHabit);
        
        result.fold(
          (failure) {
            if (kDebugMode) print('❌ Error al decrementar: ${failure.message}');
            // Revertir cambio optimista si falla
            updateHabitProgressOptimistic(todayProgress);
          },
          (updatedProgress) {
            if (kDebugMode) print('✅ Progreso decrementado: ${updatedProgress.dailyCounter}');
            updateHabitProgressOptimistic(updatedProgress);
            _notifyPendingChanges();
          },
        );
      });

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error inesperado: $e');
      return false;
    }
  }

  /// Actualiza un hábito existente (funciona offline)
  /// 🚀 ACTUALIZACIÓN OPTIMISTA: Actualiza UI inmediatamente y persiste en segundo plano
  Future<bool> updateHabit(HabitEntity updatedHabit) async {
    try {
      // 1. Validar que el hábito existe en la lista local
      final habitIndex = _habits.indexWhere((h) => h.id == updatedHabit.id);
      if (habitIndex == -1) {
        if (kDebugMode) print('⚠️ Hábito no encontrado en la lista local');
        return false;
      }

      // Guardar el hábito original por si necesitamos revertir
      final originalHabit = _habits[habitIndex];
      
      // 🚀 2. Actualización optimista INMEDIATA en la UI
      _habits[habitIndex] = updatedHabit;
      notifyListeners();
      
      if (kDebugMode) print('✅ UI actualizada inmediatamente con el hábito modificado');

      // 💾 3. Ejecutar caso de uso en segundo plano (NO bloqueante)
      _updateHabitUseCase.execute(habit: updatedHabit).then((result) {
        result.fold(
          (failure) {
            if (kDebugMode) print('❌ Error al actualizar hábito: ${failure.message}');
            // Revertir cambio optimista si falla
            final idx = _habits.indexWhere((h) => h.id == updatedHabit.id);
            if (idx != -1) {
              _habits[idx] = originalHabit;
              notifyListeners();
            }
            _setError('Error al actualizar hábito: ${failure.message}');
          },
          (_) {
            if (kDebugMode) print('✅ Hábito actualizado exitosamente: ${updatedHabit.id}');
            // Notificar cambios pendientes al SyncProvider
            _notifyPendingChanges();
          },
        );
      });

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error inesperado en updateHabit: $e');
      _setError('Error inesperado al actualizar hábito: ${e.toString()}');
      return false;
    }
  }

  /// Crea un nuevo hábito (funciona offline)
  /// 🚀 ACTUALIZACIÓN OPTIMISTA: Genera UUID aquí y lo usa en SQLite y Supabase
  Future<String?> createHabit(HabitEntity habit) async {
    try {
      // 🎯 1. Generar UUID único que se usará en TODAS partes (SQLite + Supabase)
      final String habitId = const Uuid().v4();
      final HabitEntity habitWithId = habit.copyWith(id: habitId);
      
      // 🚀 2. ACTUALIZACIÓN OPTIMISTA: Agregar a la UI inmediatamente
      _habits.insert(0, habitWithId);
      notifyListeners();
      
      if (kDebugMode) print('✅ Hábito agregado a la UI con UUID: $habitId');

      // 💾 3. Ejecutar caso de uso en segundo plano (NO bloqueante)
      _createHabitUseCase.execute(habit: habitWithId).then((result) {
        result.fold(
          (failure) {
            if (kDebugMode) print('❌ Error al crear hábito: ${failure.message}');
            
            // Revertir cambio optimista si falla
            _habits.removeWhere((h) => h.id == habitId);
            notifyListeners();
            _setError('Error al crear hábito: ${failure.message}');
          },
          (returnedId) {
            // ✅ El ID retornado DEBE ser el mismo que generamos
            if (returnedId != habitId) {
              if (kDebugMode) {
                print('⚠️ ADVERTENCIA: El repositorio retornó un ID diferente');
                print('   Esperado: $habitId');
                print('   Recibido: $returnedId');
              }
            }
            
            if (kDebugMode) print('✅ Hábito guardado exitosamente: $habitId');
            
            // Notificar cambios pendientes al SyncProvider
            _notifyPendingChanges();
          },
        );
      });

      return habitId; // Retornar inmediatamente el UUID generado
    } catch (e) {
      if (kDebugMode) print('❌ Error inesperado en createHabit: $e');
      _setError('Error inesperado al crear hábito: ${e.toString()}');
      return null;
    }
  }

  /// Crea un nuevo registro de progreso para un hábito
  /// 🚀 ACTUALIZACIÓN OPTIMISTA: Genera UUID aquí y lo usa en SQLite y Supabase
  Future<String?> createHabitProgress(
    String habitId,
    int dailyGoal,
  ) async {
    try {
      final String todayString = DateInfoUtils.todayString();

      // 🔍 Buscar el hábito
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      
      if (habitIndex == -1) {
        if (kDebugMode) print('⚠️ Hábito con ID $habitId no encontrado');
        return null;
      }

      // 🎯 1. Generar UUID único que se usará en TODAS partes
      final String progressId = const Uuid().v4();
      
      // 🚀 2. ACTUALIZACIÓN OPTIMISTA: Agregar a la UI inmediatamente
      final HabitProgress newProgress = HabitProgress(
        id: progressId,
        habitId: habitId,
        date: todayString,
        dailyGoal: dailyGoal,
        dailyCounter: 0,
      );
      
      final updatedHabit = _habits[habitIndex].copyWith(
        progress: [..._habits[habitIndex].progress, newProgress],
      );
      _habits[habitIndex] = updatedHabit;
      notifyListeners();
      
      if (kDebugMode) print('✅ Progreso agregado a la UI con UUID: $progressId');

      // 💾 3. Guardar en el repositorio (SQLite + Supabase con el MISMO UUID)
      final result = await _repository.createHabitProgress(
        habitProgress: newProgress,
      );

      return result.fold(
        (failure) {
          if (kDebugMode) print('❌ Error al crear progreso: ${failure.message}');
          
          // Revertir cambio optimista si falla
          _habits[habitIndex].progress.removeWhere((p) => p.id == progressId);
          notifyListeners();
          
          return null;
        },
        (returnedId) {
          // ✅ El ID retornado DEBE ser el mismo que generamos
          if (returnedId != progressId) {
            if (kDebugMode) {
              print('⚠️ ADVERTENCIA: El repositorio retornó un ID diferente');
              print('   Esperado: $progressId');
              print('   Recibido: $returnedId');
            }
          }
          
          if (kDebugMode) print('✅ Progreso guardado exitosamente: $progressId');
          
          // Notificar cambios pendientes al SyncProvider
          _notifyPendingChanges();
          
          return progressId; // Retornar el UUID que generamos aquí
        },
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error createHabitProgress: $e');
      return null;
    }
  }

  /// Elimina un hábito (funciona offline)
  /// 🚀 ACTUALIZACIÓN OPTIMISTA: Elimina de la UI inmediatamente
  Future<bool> deleteHabit(String habitId) async {
    try {
      // Guardar el hábito por si necesitamos revertir
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      final HabitEntity? deletedHabit = habitIndex != -1 ? _habits[habitIndex] : null;
      
      // 🚀 1. Actualizar UI inmediatamente
      _habits.removeWhere((h) => h.id == habitId);
      notifyListeners();

      // 💾 2. Ejecutar caso de uso en segundo plano (NO bloqueante)
      _deleteHabitUseCase.execute(habitId: habitId).then((result) {
        result.fold(
          (failure) {
            if (kDebugMode) print('❌ Error al eliminar hábito: ${failure.message}');
            
            // Revertir cambio optimista si falla
            if (deletedHabit != null && habitIndex != -1) {
              _habits.insert(habitIndex, deletedHabit);
              notifyListeners();
            }
            
            _setError('Error al eliminar hábito: ${failure.message}');
          },
          (_) {
            if (kDebugMode) print('✅ Hábito eliminado exitosamente: $habitId');
            // Notificar cambios pendientes al SyncProvider
            _notifyPendingChanges();
          },
        );
      });

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error inesperado en deleteHabit: $e');
      _setError('Error inesperado al eliminar hábito: ${e.toString()}');
      return false;
    }
  }
}

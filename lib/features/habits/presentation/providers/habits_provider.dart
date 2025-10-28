import 'dart:async';
import 'package:find_your_mind/core/config/dependency_injection.dart';
import 'package:find_your_mind/core/constants/string_constants.dart';
import 'package:find_your_mind/core/utils/date_utils.dart';
import 'package:find_your_mind/features/habits/data/repositories/habit_repository_impl.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/shared/presentation/providers/sync_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class HabitsProvider extends ChangeNotifier {
  String _titleScreen = AppStrings.habitsTitle;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 0;
  final List<HabitEntity> _habits = [];
  
  // Map para rastrear operaciones en progreso por hábito (prevenir race conditions)
  final Map<String, Future<bool>> _ongoingProgressOperations = {};
  
  // Referencia al SyncProvider para notificar cambios pendientes
  SyncProvider? _syncProvider;
  
  // Constantes
  static const int _pageSize = 10;

  // Repositorio con lógica offline-first
  final HabitRepository _repository = DependencyInjection().habitRepository;

  // Timer para sincronización automática
  Timer? _syncTimer;

  // UUID del usuario de Supabase
  final String _userId = AppConstants.currentUserId;

  // Getters
  String get titleScreen => _titleScreen;
  bool get isEditing => _isEditing;
  List<HabitEntity> get habits => _habits;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  bool get hasError => _lastError != null;

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

  /// Recarga hábitos desde SQLite sin mostrar loading
  Future<void> _refreshHabitsFromLocal() async {
    try {
      print('🔄 [PROVIDER] Refrescando desde SQLite...');
      final updatedHabits = await _repository.getHabitsByEmail(_userId);
      _habits.clear();
      _habits.addAll(updatedHabits);
      notifyListeners();
      print(
        '✅ [PROVIDER] Refrescado exitoso - ${updatedHabits.length} hábitos',
      );
    } catch (e) {
      // Error no crítico - los datos ya están cargados en memoria
      if (kDebugMode)
        print('⚠️ Error al refrescar desde SQLite (datos ya en memoria): $e');
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

  /// Establece la referencia al SyncProvider para notificar cambios
  void setSyncProvider(SyncProvider syncProvider) {
    _syncProvider = syncProvider;
  }

  /// Notifica al SyncProvider que hay cambios pendientes
  void _notifyPendingChanges() {
    _syncProvider?.markPendingChanges();
  }

  void changeTitle(String newTitle) {
    if (_titleScreen == newTitle) return;
    _titleScreen = newTitle;
    notifyListeners();
  }

  void resetTitle() {
    if (_titleScreen != AppStrings.habitsTitle) {
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
      final List<HabitEntity> habits = await _repository
          .getHabitsByEmailPaginated(
            email: _userId,
            limit: _pageSize,
            offset: 0,
          );

      print('✅ [PROVIDER] Recibidos ${habits.length} hábitos del repository');
      _habits.addAll(habits);
      _hasMore = habits.length == _pageSize;
      _currentPage = 1;
      _isLoading = false;
      notifyListeners();

      // Sincronización en segundo plano (no bloquea la UI)
      await _syncInBackground();
    } catch (e) {
      print('❌ [PROVIDER] Error loadHabits: $e');
      if (kDebugMode) print('❌ Error loadHabits: $e');
    }
  }

  /// Carga más hábitos con paginación
  Future<void> loadMoreHabits() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      final List<HabitEntity> newHabits = await _repository
          .getHabitsByEmailPaginated(
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

  /// Incrementa el contador de progreso del día actual con actualización optimista
  /// Permite múltiples clics rápidos para registrar varias completaciones
  Future<bool> incrementHabitProgress(String habitId) async {
    // 🔒 Si ya hay una operación en progreso, esperar a que termine
    if (_ongoingProgressOperations.containsKey(habitId)) {
      if (kDebugMode) print('⏳ Esperando operación previa para: $habitId');
      await _ongoingProgressOperations[habitId];
    }

    // Crear la nueva operación
    final operation = _executeIncrementProgress(habitId);
    _ongoingProgressOperations[habitId] = operation;

    try {
      return await operation;
    } finally {
      _ongoingProgressOperations.remove(habitId);
    }
  }

  /// Método interno que ejecuta el incremento
  Future<bool> _executeIncrementProgress(String habitId) async {
    try {
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) {
        if (kDebugMode) print('⚠️ Hábito no encontrado: $habitId');
        return false;
      }

      final habit = _habits[habitIndex];
      final String todayString = DateInfoUtils.todayString();
      
      // 🔍 Obtener el estado MÁS RECIENTE del hábito en cada llamada
      final currentHabit = _habits[habitIndex];
      final int todayIndex = currentHabit.progress.indexWhere(
        (progress) => progress.date == todayString,
      );

      if (todayIndex == -1) {
        // Crear nuevo progreso para hoy con contador en 1
        final String progressId = const Uuid().v4();
        final newProgress = HabitProgress(
          id: progressId,
          habitId: habitId,
          date: todayString,
          dailyGoal: habit.dailyGoal,
          dailyCounter: 1,
        );

        // 🚀 Actualización optimista INMEDIATA en la UI
        updateHabitProgressOptimistic(newProgress);

        // 💾 Persistir en segundo plano (no bloqueante, igual que el update)
        _repository.createHabitProgress(habitProgress: newProgress).then((result) {
          result.fold(
            (failure) {
              if (kDebugMode) print('❌ Error al crear progreso: ${failure.message}');
              // Revertir cambio optimista si falla
              final habitIdx = _habits.indexWhere((h) => h.id == habitId);
              if (habitIdx != -1) {
                _habits[habitIdx].progress.removeWhere((p) => p.id == progressId);
                notifyListeners();
              }
            },
            (_) {
              if (kDebugMode) print('✅ Progreso creado: $progressId');
              // Notificar cambios pendientes al SyncProvider
              _notifyPendingChanges();
            },
          );
        });

        return true;
      } else {
        // Actualizar progreso existente
        final todayProgress = currentHabit.progress[todayIndex];
        
        // Validar si ya se alcanzó la meta
        if (todayProgress.dailyCounter >= habit.dailyGoal) {
          if (kDebugMode) print('⚠️ Meta diaria ya alcanzada: ${todayProgress.dailyCounter}/${habit.dailyGoal}');
          return false;
        }

        // Incrementar contador
        final updatedProgress = todayProgress.copyWith(
          dailyCounter: todayProgress.dailyCounter + 1,
        );

        // 🚀 Actualización optimista INMEDIATA en la UI
        updateHabitProgressOptimistic(updatedProgress);

        // 💾 Persistir en segundo plano (no bloqueante)
        _repository.updateHabitProgress(
          habitId,
          todayProgress.id,
          updatedProgress.dailyCounter,
        ).then((result) {
          result.fold(
            (failure) {
              if (kDebugMode) print('❌ Error al actualizar progreso: ${failure.message}');
              // Revertir cambio optimista si falla
              updateHabitProgressOptimistic(todayProgress);
            },
            (_) {
              if (kDebugMode) print('✅ Progreso actualizado: ${updatedProgress.dailyCounter}');
              // Notificar cambios pendientes al SyncProvider
              _notifyPendingChanges();
            },
          );
        });

        return true;
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error incrementHabitProgress: $e');
      return false;
    }
  }

  /// Decrementa el contador de progreso del día actual con actualización optimista
  /// Permite múltiples clics rápidos para deshacer completaciones
  Future<bool> decrementHabitProgress(String habitId) async {
    // 🔒 Si ya hay una operación en progreso, esperar a que termine
    if (_ongoingProgressOperations.containsKey(habitId)) {
      if (kDebugMode) print('⏳ Esperando operación previa para: $habitId');
      await _ongoingProgressOperations[habitId];
    }

    // Crear la nueva operación
    final operation = _executeDecrementProgress(habitId);
    _ongoingProgressOperations[habitId] = operation;

    try {
      return await operation;
    } finally {
      _ongoingProgressOperations.remove(habitId);
    }
  }

  /// Método interno que ejecuta el decremento
  Future<bool> _executeDecrementProgress(String habitId) async {
    try {
      final habitIndex = _habits.indexWhere((h) => h.id == habitId);
      if (habitIndex == -1) {
        if (kDebugMode) print('⚠️ Hábito no encontrado: $habitId');
        return false;
      }

      final String todayString = DateInfoUtils.todayString();
      
      // 🔍 Obtener el estado MÁS RECIENTE del hábito
      final currentHabit = _habits[habitIndex];
      final int todayIndex = currentHabit.progress.indexWhere(
        (progress) => progress.date == todayString,
      );

      if (todayIndex == -1) {
        if (kDebugMode) print('⚠️ No hay progreso para hoy');
        return false;
      }

      final todayProgress = currentHabit.progress[todayIndex];

      if (todayProgress.dailyCounter <= 0) {
        if (kDebugMode) print('⚠️ El contador ya está en 0');
        return false;
      }

      // Decrementar contador
      final updatedProgress = todayProgress.copyWith(
        dailyCounter: todayProgress.dailyCounter - 1,
      );

      // 🚀 Actualización optimista INMEDIATA en la UI
      updateHabitProgressOptimistic(updatedProgress);

      // 💾 Persistir en segundo plano (no bloqueante)
      _repository.updateHabitProgress(
        habitId,
        todayProgress.id,
        updatedProgress.dailyCounter,
      ).then((result) {
        result.fold(
          (failure) {
            if (kDebugMode) print('❌ Error al decrementar progreso: ${failure.message}');
            // Revertir cambio optimista si falla
            updateHabitProgressOptimistic(todayProgress);
          },
          (_) {
            if (kDebugMode) print('✅ Progreso decrementado: ${updatedProgress.dailyCounter}');
            // Notificar cambios pendientes al SyncProvider
            _notifyPendingChanges();
          },
        );
      });

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error decrementHabitProgress: $e');
      return false;
    }
  }

  /// Actualiza un hábito existente (funciona offline)
  /// 🚀 ACTUALIZACIÓN OPTIMISTA: Actualiza UI inmediatamente y persiste en segundo plano
  Future<bool> updateHabit(HabitEntity updatedHabit) async {
    try {
      // 🚀 1. ACTUALIZACIÓN OPTIMISTA: Actualizar la UI inmediatamente
      final habitIndex = _habits.indexWhere((h) => h.id == updatedHabit.id);
      if (habitIndex == -1) {
        if (kDebugMode) print('⚠️ Hábito no encontrado en la lista local');
        return false;
      }

      // Guardar el hábito original por si necesitamos revertir
      final originalHabit = _habits[habitIndex];
      
      // Actualizar en la UI inmediatamente
      _habits[habitIndex] = updatedHabit;
      notifyListeners();
      
      if (kDebugMode) print('✅ UI actualizada inmediatamente con el hábito modificado');

      // 💾 2. Persistir en segundo plano (no bloqueante)
      _repository.updateHabit(updatedHabit).then((result) {
        result.fold(
          (failure) {
            if (kDebugMode) print('❌ Error al actualizar hábito en BD: ${failure.message}');
            // Revertir cambio optimista si falla
            final idx = _habits.indexWhere((h) => h.id == updatedHabit.id);
            if (idx != -1) {
              _habits[idx] = originalHabit;
              notifyListeners();
            }
            _setError('Error al actualizar hábito: ${failure.message}');
          },
          (_) {
            if (kDebugMode) print('✅ Hábito actualizado en BD: ${updatedHabit.id}');
            // Notificar cambios pendientes al SyncProvider
            _notifyPendingChanges();
          },
        );
      });

      return true;
    } catch (e) {
      if (kDebugMode) print('❌ Error updateHabit: $e');
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

      // 💾 3. Guardar en el repositorio (SQLite + Supabase con el MISMO UUID)
      final result = await _repository.createHabit(habitWithId);
      
      return result.fold(
        (failure) {
          if (kDebugMode) print('❌ Error al crear hábito: ${failure.message}');
          
          // Revertir cambio optimista si falla
          _habits.removeWhere((h) => h.id == habitId);
          notifyListeners();
          
          return null;
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
          
          return habitId; // Retornar el UUID que generamos aquí
        },
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error createHabit: $e');
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
      
      _habits[habitIndex].progress.add(newProgress);
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
  Future<bool> deleteHabit(String habitId) async {
    try {
      // Actualizar UI inmediatamente
      _habits.removeWhere((h) => h.id == habitId);
      notifyListeners();

      // Eliminar del repositorio (SQLite + sync automático)
      final result = await _repository.deleteHabit(habitId);

      return result.fold(
        (failure) {
          if (kDebugMode)
            print('❌ Error al eliminar hábito: ${failure.message}');
          return false;
        },
        (_) {
          // Notificar cambios pendientes al SyncProvider
          _notifyPendingChanges();
          return true;
        },
      );
    } catch (e) {
      if (kDebugMode) print('❌ Error deleteHabit: $e');
      return false;
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

  Future<void> inspectDatabase() async {
    final db = await DependencyInjection().databaseHelper.database;

    print('\n═══════════════════════════════════════');
    print('🔍 INSPECCIÓN DE BASE DE DATOS');
    print('═══════════════════════════════════════');

    // Tablas existentes
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );
    print('📁 Tablas: ${tables.map((t) => t['name']).join(', ')}');

    // Conteo de registros
    final habitsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM habits'),
    );
    final progressCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM habit_progress'),
    );
    final pendingCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM pending_sync'),
    );

    print('📊 Hábitos: $habitsCount');
    print('📊 Progresos: $progressCount');
    print('📊 Pendientes de sync: $pendingCount');

    // Muestra de datos
    final sampleHabits = await db.query('habits', limit: 3);
    print('📄 Muestra de hábitos:');
    sampleHabits.forEach((h) => print('  - ${h['id']}: ${h['title']}'));

    print('═══════════════════════════════════════\n');
  }
}

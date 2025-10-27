import 'dart:developer' as developer;
import 'package:find_your_mind/core/config/dependency_injection.dart';
import 'package:find_your_mind/core/utils/date_utils.dart' as custom_date_utils;
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/domain/repositories/habit_repository.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:uuid/uuid.dart';

/// Gestiona las operaciones de progreso de un hábito (incrementar/decrementar)
/// 
/// Maneja la lógica de negocio para:
/// - Crear progreso para el día actual
/// - Incrementar contador diario
/// - Decrementar contador diario
/// - Validaciones de límites
class HabitProgressManager {
  final HabitEntity habit;
  final HabitsProvider provider;
  final HabitRepository _repository;

  HabitProgressManager({
    required this.habit,
    required this.provider,
    HabitRepository? repository,
  }) : _repository = repository ?? DependencyInjection().habitRepository;

  /// Obtiene el progreso de hoy o crea uno nuevo si no existe
  HabitProgress _getTodayProgress() {
    final String todayString = custom_date_utils.DateInfoUtils.todayString();
    final int todayIndex = habit.progress.indexWhere(
      (progress) => progress.date == todayString,
    );

    if (todayIndex != -1) {
      return habit.progress[todayIndex];
    }

    // Retornar progreso vacío si no existe
    return HabitProgress(
      id: '',
      habitId: habit.id,
      date: todayString,
      dailyGoal: habit.dailyGoal,
      dailyCounter: 0,
    );
  }

  /// Verifica si el progreso ya alcanzó la meta diaria
  bool _hasReachedDailyGoal(HabitProgress progress) {
    return progress.dailyCounter >= habit.dailyGoal;
  }

  /// Incrementa el contador de progreso del día actual con actualización optimista
  Future<bool> incrementProgress() async {
    final todayProgress = _getTodayProgress();

    print('*' * 50);
    print('todayProgressInfo: ${todayProgress.id} - ${todayProgress.dailyCounter}');
    print('habitDailyGoal: ${habit.dailyGoal}');
    print('*' * 50);
    
    // Validar si ya se alcanzó la meta
    if (todayProgress.id.isNotEmpty && _hasReachedDailyGoal(todayProgress)) {
      developer.log(
        'Meta diaria ya alcanzada: ${todayProgress.dailyCounter} de ${habit.dailyGoal}'
      );
      return false;
    }

    try {
      if (todayProgress.id.isEmpty) {
        // Crear nuevo progreso con actualización optimista
        return await _createNewProgressOptimistic();
      } else {
        // Actualizar progreso existente con actualización optimista
        return await _updateExistingProgressOptimistic(todayProgress, increment: true);
      }
    } catch (e) {
      developer.log('Error al incrementar progreso: $e');
      return false;
    }
  }

  /// Decrementa el contador de progreso del día actual con actualización optimista
  Future<bool> decrementProgress() async {
    final todayProgress = _getTodayProgress();
    
    // Validar que existe progreso para hoy
    if (todayProgress.id.isEmpty) {
      developer.log('No hay progreso para hoy para decrementar.');
      return false;
    }

    // Validar que el contador no esté en 0
    if (todayProgress.dailyCounter <= 0) {
      developer.log('El contador diario ya está en 0, no se puede decrementar.');
      return false;
    }

    try {
      return await _updateExistingProgressOptimistic(todayProgress, increment: false);
    } catch (e) {
      developer.log('Error al decrementar progreso: $e');
      return false;
    }
  }

  /// Crea un nuevo registro de progreso para hoy con actualización optimista
  /// 1. Actualiza la UI inmediatamente
  /// 2. Hace la petición al backend
  /// 3. Revierte si falla
  Future<bool> _createNewProgressOptimistic() async {
    final String todayString = custom_date_utils.DateInfoUtils.todayString();
    
    // Generar ID temporal para la actualización optimista
    final tempId = const Uuid().v4();
    
    // 1. ACTUALIZACIÓN OPTIMISTA: Actualizar UI inmediatamente (sin await)
    final optimisticProgress = HabitProgress(
      id: tempId,
      habitId: habit.id,
      date: todayString,
      dailyGoal: habit.dailyGoal,
      dailyCounter: 1,
    );
    
    provider.updateHabitProgressOptimistic(optimisticProgress);
    developer.log('✅ UI actualizada instantáneamente con progreso temporal');

    // 2. PETICIÓN AL BACKEND (en segundo plano)
    try {
      final newProgressId = await _repository.createHabitProgress(
        habitId: habit.id,
        date: todayString,
        dailyGoal: habit.dailyGoal,
        dailyCounter: 1,
      );

      if (newProgressId == null) {
        developer.log('❌ Error: No se pudo crear el progreso en el backend');
        // 3. REVERTIR: Eliminar el progreso temporal
        _revertProgressSync(tempId);
        return false;
      }

      // Actualizar con el ID real del backend (solo en UI)
      final realProgress = optimisticProgress.copyWith(id: newProgressId);
      provider.updateHabitProgressOptimistic(realProgress);
      developer.log('✅ Progreso confirmado con ID real: $newProgressId');
      
      return true;
    } catch (e) {
      developer.log('❌ Error al crear progreso en backend: $e');
      // 3. REVERTIR: Eliminar el progreso temporal
      _revertProgressSync(tempId);
      return false;
    }
  }

  /// Actualiza un progreso existente con actualización optimista
  /// 1. Actualiza la UI inmediatamente
  /// 2. Hace la petición al backend
  /// 3. Revierte si falla
  Future<bool> _updateExistingProgressOptimistic(
    HabitProgress progress, {
    required bool increment,
  }) async {
    final int previousCounter = progress.dailyCounter;
    final int newCounter = increment
        ? progress.dailyCounter + 1
        : progress.dailyCounter - 1;

    // 1. ACTUALIZACIÓN OPTIMISTA: Actualizar UI inmediatamente (sin await)
    final optimisticProgress = progress.copyWith(dailyCounter: newCounter);
    provider.updateHabitProgressOptimistic(optimisticProgress);
    developer.log('✅ UI actualizada instantáneamente: $newCounter (anterior: $previousCounter)');

    // 2. PETICIÓN AL BACKEND (en segundo plano)
    try {
      await _repository.updateHabitProgress(
        habit.id,
        progress.id,
        newCounter,
      );

      developer.log(
        '✅ Progreso confirmado en backend: ${increment ? "incrementado" : "decrementado"} a $newCounter'
      );
      
      return true;
    } catch (e) {
      developer.log('❌ Error al actualizar progreso en backend: $e');
      // 3. REVERTIR: Restaurar el contador anterior
      final revertedProgress = progress.copyWith(dailyCounter: previousCounter);
      provider.updateHabitProgressOptimistic(revertedProgress);
      developer.log('⏪ Progreso revertido a: $previousCounter');
      return false;
    }
  }

  /// Revierte un progreso temporal eliminándolo de la lista (síncrono)
  void _revertProgressSync(String tempId) {
    // Buscar el hábito con el progreso temporal
    final currentHabits = provider.habits;
    final habitIndex = currentHabits.indexWhere((h) => h.id == habit.id);
    if (habitIndex == -1) return;

    final currentHabit = currentHabits[habitIndex];
    final progressIndex = currentHabit.progress.indexWhere((p) => p.id == tempId);
    if (progressIndex == -1) return;

    // Crear un progreso con contador 0 para revertir
    final revertedProgress = currentHabit.progress[progressIndex].copyWith(
      dailyCounter: 0,
    );
    
    // Actualizar solo la UI de forma síncrona
    provider.updateHabitProgressOptimistic(revertedProgress);
    
    developer.log('⏪ Progreso temporal revertido: $tempId');
  }

  /// Obtiene el contador de progreso del día actual
  int getTodayCounter() {
    final todayProgress = _getTodayProgress();
    return todayProgress.dailyCounter;
  }

  /// Verifica si se puede incrementar el progreso hoy
  bool canIncrement() {
    final todayProgress = _getTodayProgress();
    return todayProgress.id.isEmpty || !_hasReachedDailyGoal(todayProgress);
  }

  /// Verifica si se puede decrementar el progreso hoy
  bool canDecrement() {
    final todayProgress = _getTodayProgress();
    return todayProgress.id.isNotEmpty && todayProgress.dailyCounter > 0;
  }
}

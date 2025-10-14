import 'dart:developer' as developer;
import 'package:find_your_mind/core/data/supabase_habits_service.dart';
import 'package:find_your_mind/core/utils/date_utils.dart' as custom_date_utils;
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';

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
  final SupabaseHabitsService supabaseService;

  HabitProgressManager({
    required this.habit,
    required this.provider,
    SupabaseHabitsService? supabaseService,
  }) : supabaseService = supabaseService ?? SupabaseHabitsService();

  /// Obtiene el progreso de hoy o crea uno nuevo si no existe
  HabitProgress _getTodayProgress() {
    final String todayString = custom_date_utils.DateUtils.todayString();
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

  /// Incrementa el contador de progreso del día actual
  Future<bool> incrementProgress() async {
    final todayProgress = _getTodayProgress();
    
    // Validar si ya se alcanzó la meta
    if (todayProgress.id.isNotEmpty && _hasReachedDailyGoal(todayProgress)) {
      developer.log(
        'Meta diaria ya alcanzada: ${todayProgress.dailyCounter} de ${habit.dailyGoal}'
      );
      return false;
    }

    try {
      if (todayProgress.id.isEmpty) {
        // Crear nuevo progreso
        return await _createNewProgress();
      } else {
        // Actualizar progreso existente
        return await _updateExistingProgress(todayProgress, increment: true);
      }
    } catch (e) {
      developer.log('Error al incrementar progreso: $e');
      return false;
    }
  }

  /// Decrementa el contador de progreso del día actual
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
      return await _updateExistingProgress(todayProgress, increment: false);
    } catch (e) {
      developer.log('Error al decrementar progreso: $e');
      return false;
    }
  }

  /// Crea un nuevo registro de progreso para hoy
  Future<bool> _createNewProgress() async {
    final String todayString = custom_date_utils.DateUtils.todayString();
    
    final newProgressId = await supabaseService.createHabitProgress(
      habitId: habit.id,
      date: todayString,
      dailyGoal: habit.dailyGoal,
      dailyCounter: 1,
    );

    if (newProgressId == null) {
      developer.log('Error: No se pudo crear el progreso');
      return false;
    }

    final newProgress = HabitProgress(
      id: newProgressId,
      habitId: habit.id,
      date: todayString,
      dailyGoal: habit.dailyGoal,
      dailyCounter: 1,
    );

    // Actualizar en el provider
    await provider.updateHabitProgress(newProgress);
    developer.log('Nuevo progreso creado para hoy con ID: $newProgressId');
    
    return true;
  }

  /// Actualiza un progreso existente
  Future<bool> _updateExistingProgress(
    HabitProgress progress, {
    required bool increment,
  }) async {
    final int newCounter = increment
        ? progress.dailyCounter + 1
        : progress.dailyCounter - 1;

    await supabaseService.updateHabitProgress(
      habit.id,
      progress.id,
      newCounter,
    );

    final updatedProgress = progress.copyWith(dailyCounter: newCounter);
    await provider.updateHabitProgress(updatedProgress);

    developer.log(
      'Progreso ${increment ? "incrementado" : "decrementado"} para hoy: $newCounter'
    );
    
    return true;
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

import 'dart:async';
import 'package:find_your_mind/core/constants/animation_constants.dart';
import 'package:find_your_mind/core/utils/date_utils.dart' as custom_date_utils;
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/item_habit/slidable_item.dart';
import 'package:find_your_mind/features/habits/utils/habit_progress_manager.dart';
import 'package:find_your_mind/features/habits/utils/timer.dart';
import 'package:flutter/material.dart';

class ItemHabit extends StatefulWidget {
  final HabitEntity itemHabit;
  final HabitsProvider habitsProvider;

  const ItemHabit({
    super.key, 
    required this.itemHabit,
    required this.habitsProvider
  });

  @override
  State<ItemHabit> createState() => _ItemHabitState();
}

class _ItemHabitState extends State<ItemHabit> {
  HabitTimerManager? _timerManager;
  late HabitProgressManager _progressManager;
  late String _timeSinceStart;
  bool _isFlashingRed = false;
  bool _isFlashingGreen = false;

  void _updateTimeSinceStart() {
    if (!mounted) return;
    
    setState(() {
      _timeSinceStart = widget.itemHabit.timeSinceStart;
    });
  }

  @override
  void initState() {
    super.initState();
    _timeSinceStart = widget.itemHabit.timeSinceStart;

    // Inicializar el progress manager
    _progressManager = HabitProgressManager(
      habit: widget.itemHabit,
      provider: widget.habitsProvider,
    );

    // Inicializar y arrancar el timer manager
    final startDate = DateTime.parse(widget.itemHabit.initialDate);
    _timerManager = HabitTimerManager(
      startDate: startDate,
      onUpdate: _updateTimeSinceStart,
    );
    _timerManager?.start();
  }

  @override
  void dispose() {
    _timerManager?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final currentTime = widget.itemHabit.timeSinceStart;
    if (_timeSinceStart != currentTime) {
      _timeSinceStart = currentTime;
    }

    // Buscar el progreso de HOY específicamente
    final String todayString = custom_date_utils.DateInfoUtils.todayString();
    final int todayIndex = widget.itemHabit.progress.indexWhere(
      (progress) => progress.date == todayString,
    );

    // Contador de progreso de hoy (si existe), sino 0
    final int counterToday = todayIndex != -1 
        ? widget.itemHabit.progress[todayIndex].dailyCounter 
        : 0;
    
    final int dailyGoal = widget.itemHabit.dailyGoal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: SlidableItem(
          habit: widget.itemHabit,
          habitsProvider: widget.habitsProvider,
          timeSinceStart: _timeSinceStart,
          counterToday: counterToday,
          dailyGoal: dailyGoal,
          isFlashingRed: _isFlashingRed,
          isFlashingGreen: _isFlashingGreen,
          onTap: _onTapCompleteHabit,
          onLongPress: _onLongPress,
        ),
      ),
    );
  }

  Future<void> _onTapCompleteHabit() async {
    // Mostrar animación de éxito INMEDIATAMENTE
    if (mounted) {
      setState(() => _isFlashingGreen = true);
    }

    // Incrementar progreso en segundo plano (la UI ya se actualiza instantáneamente)
    // NO usamos await para que la animación no se quede esperando
    _progressManager.incrementProgress().then((
      success) {
      // Si falló, podríamos mostrar un feedback adicional aquí
      if (!success && mounted) {
        // Opcional: mostrar un snackbar o algún indicador de error
      }
    });
    
    // Esperar que termine la animación
    await Future.delayed(AnimationConstants.fastAnimation);
    
    if (mounted) {
      setState(() => _isFlashingGreen = false);
    }
  }

  Future<void> _onLongPress() async {
    // Mostrar animación de decremento INMEDIATAMENTE
    if (mounted) {
      setState(() => _isFlashingRed = true);
    }

    // Decrementar progreso en segundo plano (la UI ya se actualiza instantáneamente)
    // NO usamos await para que la animación no se quede esperando
    _progressManager.decrementProgress().then((success) {
      // Si falló, podríamos mostrar un feedback adicional aquí
      if (!success && mounted) {
        // Opcional: mostrar un snackbar o algún indicador de error
      }
    });
    
    // Esperar que termine la animación
    await Future.delayed(AnimationConstants.fastAnimation);
    
    if (mounted) {
      setState(() => _isFlashingRed = false);
    }
  }
}
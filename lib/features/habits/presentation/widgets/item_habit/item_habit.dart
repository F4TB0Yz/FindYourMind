import 'dart:async';
import 'package:find_your_mind/core/constants/animation_constants.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/item_habit/slidable_item.dart';
import 'package:find_your_mind/features/habits/utils/timer.dart';
import 'package:flutter/material.dart';

class ItemHabit extends StatefulWidget {
  final HabitEntity itemHabit;
  final HabitsProvider habitsProvider;

  const ItemHabit({
    super.key,
    required this.itemHabit,
    required this.habitsProvider,
  });

  @override
  State<ItemHabit> createState() => _ItemHabitState();
}

class _ItemHabitState extends State<ItemHabit> {
  HabitTimerManager? _timerManager;
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

    // 🔄 Obtener contador y meta DESDE EL PROVIDER (datos actualizados)
    final int counterToday = widget.habitsProvider.getTodayCount(widget.itemHabit.id);
    final int dailyGoal = widget.itemHabit.dailyGoal;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SlidableItem(
        habit: widget.itemHabit,
        habitsProvider: widget.habitsProvider,
        timeSinceStart: _timeSinceStart,
        counterToday: counterToday,
        dailyGoal: dailyGoal,
        isFlashingRed: _isFlashingRed,
        isFlashingGreen: _isFlashingGreen,
        triggerCompletion: _triggerCompletion,
        onTap: _onTapCompleteHabit,
        onLongPress: _onLongPress,
      ),
    );
  }

  bool _triggerCompletion = false;

  Future<void> _onTapCompleteHabit() async {
    // ✅ Validar ANTES de incrementar usando el provider
    if (!widget.habitsProvider.canIncrement(widget.itemHabit.id)) {
      // Ya alcanzó la meta diaria, no hacer nada
      return;
    }

    final int counterBefore = widget.habitsProvider.getTodayCount(widget.itemHabit.id);
    
    // 🚀 Incrementar y obtener resultado
    final bool success = await widget.habitsProvider.updateHabitCounter(widget.itemHabit.id);

    // Mostrar animación SOLO si fue exitoso
    if (success && mounted) {
      final int counterAfter = widget.habitsProvider.getTodayCount(widget.itemHabit.id);
      
      // Dopamina: Disparar partículas si se completó el 100%
      final bool justCompleted = counterAfter >= widget.itemHabit.dailyGoal && counterBefore < widget.itemHabit.dailyGoal;

      setState(() {
        _isFlashingGreen = true;
        if (justCompleted) {
          _triggerCompletion = true;
        }
      });

      await Future.delayed(AnimationConstants.fastAnimation);

      if (mounted) {
        setState(() {
          _isFlashingGreen = false;
          _triggerCompletion = false;
        });
      }
    }
  }

  Future<void> _onLongPress() async {
    // ✅ Validar ANTES de decrementar usando el provider
    if (!widget.habitsProvider.canDecrement(widget.itemHabit.id)) {
      // Ya está en 0, no hacer nada
      return;
    }

    // 🚀 Decrementar y obtener resultado
    final bool success = await widget.habitsProvider.decrementHabitProgress(widget.itemHabit.id);

    // Mostrar animación SOLO si fue exitoso
    if (success && mounted) {
      setState(() => _isFlashingRed = true);

      await Future.delayed(AnimationConstants.fastAnimation);

      if (mounted) {
        setState(() => _isFlashingRed = false);
      }
    }
  }
}

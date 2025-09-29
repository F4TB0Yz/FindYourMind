import 'dart:async';
import 'dart:developer' as developer;
import 'package:find_your_mind/core/data/supabase_habits_service.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ItemHabit extends StatefulWidget {
  final HabitEntity itemHabit;

  const ItemHabit({
    super.key, 
    required this.itemHabit
  });

  @override
  State<ItemHabit> createState() => _ItemHabitState();
}

class _ItemHabitState extends State<ItemHabit> {
  Timer? _timer;
  late String _timeSinceStart;

  void _updateTimeSinceStart() {
    if (mounted) {
      setState(() {
        _timeSinceStart = widget.itemHabit.timeSinceStart;
        // Para depuración
        developer.log('Timer actualizado: $_timeSinceStart');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Establecer el valor inicial
    _timeSinceStart = widget.itemHabit.timeSinceStart;

    // Determinar el intervalo de actualización basado en la antigüedad
    final now = DateTime.now();
    final start = DateTime.parse(widget.itemHabit.initialDate);
    final difference = now.difference(start);
    
    // Para segundos, minutos y horas, actualizamos cada segundo
    if (difference.inHours < 24) {
      developer.log('Iniciando timer para actualización por segundos');
      // Actualizar inmediatamente y luego cada segundo
      _updateTimeSinceStart();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateTimeSinceStart();
      });
    } else if (difference.inDays < 7) {
      // Para días, actualizamos cada hora
      developer.log('Iniciando timer para actualización por horas');
      _updateTimeSinceStart();
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        _updateTimeSinceStart();
      });
    }
    // Para semanas, meses o años no necesitamos actualizaciones frecuentes
    // ya que no cambiarán tan a menudo
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final SupabaseHabitsService supabaseService = SupabaseHabitsService();
    final currentTime = widget.itemHabit.timeSinceStart;
    if (_timeSinceStart != currentTime) {
      _timeSinceStart = currentTime;
    }

    return GestureDetector(
      onTap: () async {
        developer.log('Hábito seleccionado: ${widget.itemHabit.title}');
        // Aquí puedes manejar la acción al tocar el hábito
        final todayString = DateTime.now().toIso8601String().substring(0, 10); // "2025-09-24"
        
        for (HabitProgress progress in widget.itemHabit.progress) {
          developer.log('Progreso: id=${progress.id}, date=${progress.date}, dailyCounter=${progress.dailyCounter}');
        } 

        int indexProgress = widget.itemHabit.progress.indexWhere(
          (HabitProgress progress) => progress.date == todayString,
        );

        if (indexProgress == -1) {
          developer.log('No progress entry for today ($todayString); cannot update counter.');
          // Optionally: create a new progress entry here if your service exposes a create method.
          return;
        }

        HabitProgress todayProgress = widget.itemHabit.progress[indexProgress];

        await supabaseService.updateHabitProgress(
          widget.itemHabit.id, 
          todayProgress.id, 
          todayProgress.dailyCounter + 1
        );

        print('Progreso actualizado para hoy: ${todayProgress.dailyCounter + 1}');
      },
      child: Container(
        width: double.infinity,
        height: 69,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 15),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          color: Color(0xFF2A2A2A)
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              widget.itemHabit.icon,
              width: 32,
              height: 32,
            ),
      
            const SizedBox(width: 20),
      
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.itemHabit.title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
      
                const SizedBox(height: 5),
      
                Text(
                  '0 de ${widget.itemHabit.dailyGoal} completados',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white30,
                    fontWeight: FontWeight.w500,
                  ),
                )
              ],
            ),
      
            const Spacer(),
      
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _timeSinceStart,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color.fromARGB(255, 209, 243, 18),
                    fontWeight: FontWeight.w500
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void onTapCompleteHabit(SupabaseHabitsService supabaseService) async {
    // Obtenemos la fecha de hoy en formato "YYYY-MM-DD"
    final String todayString = DateTime.now().toIso8601String().substring(0, 10); // "2025-09-24"
    // Buscamos el indice del progreso correspondiente a hoy
    int indexProgress = widget.itemHabit.progress.indexWhere(
      (HabitProgress progress) => progress.date == todayString,
    );


    if (indexProgress == -1) {
      // Crear un nuevo registro de progreso para hoy
      final newProgressId = await supabaseService.createHabitProgress(
        habitId: widget.itemHabit.id,
        date: todayString,
        dailyGoal: widget.itemHabit.dailyGoal,
        dailyCounter: 1 // Se inicia con uno por que se acaba de completar
      );

      if (newProgressId != null) {
        setState(() {
          widget.itemHabit.progress.add(HabitProgress(
            id: newProgressId,
            habitId: widget.itemHabit.id,
            date: todayString,
            dailyGoal: widget.itemHabit.dailyGoal,
            dailyCounter: 1
          ));
        });
        developer.log('Nuevo progreso creado para hoy con ID: $newProgressId');
      }
      return;
    } else {
      // Actualizar el progreso existente
      HabitProgress todayProgress = widget.itemHabit.progress[indexProgress];

      await supabaseService.updateHabitProgress(
        widget.itemHabit.id, 
        todayProgress.id, 
        todayProgress.dailyCounter + 1
      );

      setState(() {
        widget.itemHabit.progress[indexProgress] = todayProgress.copyWith(
          dailyCounter: todayProgress.dailyCounter + 1
        );
      });
    }

  }
}
import 'dart:async';
import 'dart:developer' as developer;
import 'package:find_your_mind/core/constants/animation_constants.dart';
import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/core/data/supabase_habits_service.dart';
import 'package:find_your_mind/core/utils/date_utils.dart' as custom_date_utils;
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_progress.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habit_detail_screen.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/delete_habit_dialog.dart';
import 'package:find_your_mind/shared/domain/screen_type.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

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
  Timer? _timer;
  late String _timeSinceStart;
  bool _isFlashingRed = false;
  bool _isFlashingGreen = false;
  final SupabaseHabitsService _supabaseService = SupabaseHabitsService();

  void _updateTimeSinceStart() {
    if (!mounted) {
      // Si el widget ya no está montado, cancelar el timer inmediatamente
      _timer?.cancel();
      return;
    }
    
    setState(() {
      _timeSinceStart = widget.itemHabit.timeSinceStart;
      // Para depuración
      developer.log('Timer actualizado: $_timeSinceStart');
    });
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
    
    // Menos de 1 hora: actualizar cada segundo (muestra segundos)
    if (difference.inHours < 1) {
      developer.log('Iniciando timer para actualización cada segundo');
      _updateTimeSinceStart();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateTimeSinceStart();
      });
    } 
    // Entre 1 hora y 24 horas: actualizar cada minuto (muestra horas:minutos)
    else if (difference.inHours < 24) {
      developer.log('Iniciando timer para actualización cada minuto');
      _updateTimeSinceStart();
      _timer = Timer.periodic(const Duration(minutes: 1), (_) {
        _updateTimeSinceStart();
      });
    } 
    // Más de 24 horas: actualizar cada hora (muestra días)
    else if (difference.inDays < 7) {
      developer.log('Iniciando timer para actualización cada hora');
      _updateTimeSinceStart();
      _timer = Timer.periodic(const Duration(hours: 1), (_) {
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
    final currentTime = widget.itemHabit.timeSinceStart;
    if (_timeSinceStart != currentTime) {
      _timeSinceStart = currentTime;
    }

    // Buscar el progreso de HOY específicamente
    final String todayString = custom_date_utils.DateUtils.todayString();
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
        child: Slidable(
          key: ValueKey(widget.itemHabit.id),
          startActionPane: ActionPane(
            motion: const StretchMotion(),
            extentRatio: 0.35,
            children: [
              SlidableAction(
                onPressed: (context) {
                  // Acción de editar
                  final screensProvider = Provider.of<ScreensProvider>(context, listen: false);
                  final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);

                  habitsProvider.changeTitle(widget.itemHabit.title);
                  screensProvider.setScreenWidget(HabitDetailScreen(habit: widget.itemHabit), ScreenType.habits);
                },
                backgroundColor: const Color.fromARGB(84, 80, 78, 78),
                foregroundColor: Colors.white,
                icon: Icons.info_outline_rounded,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))
              ),
              SlidableAction(
                onPressed: (context) async {
                  print('🔵 Botón de eliminar presionado');
                  
                  // Obtener referencias antes de mostrar el diálogo
                  final habitsProvider = Provider.of<HabitsProvider>(
                    context, 
                    listen: false,
                  );
                  
                  // Acción de eliminar - Mostrar diálogo de confirmación
                  final confirmed = await DeleteHabitDialog.show(
                    context, 
                    widget.itemHabit.title,
                  );
                  
                  print('🔵 Confirmación recibida: $confirmed');
                  
                  if (!confirmed) {
                    print('🔵 Eliminación cancelada por el usuario');
                    return;
                  }
                  
                  print('🔵 Iniciando eliminación del hábito con ID: ${widget.itemHabit.id}');
                  
                  try {
                    print('🔵 Llamando a deleteHabit...');
                    await habitsProvider.deleteHabit(widget.itemHabit.id);
                    print('🔵 deleteHabit completado exitosamente');
                    
                    if (context.mounted) {
                      CustomToast.showToast(
                        context: context,
                        message: 'Hábito eliminado exitosamente',
                      );
                    }
                  } catch (e) {
                    print('🔴 Error al eliminar hábito: $e');
                    if (context.mounted) {
                      CustomToast.showToast(
                        context: context,
                        message: 'Error al eliminar el hábito',
                      );
                    }
                  }
                },
                backgroundColor: const Color.fromARGB(84, 80, 78, 78),
                foregroundColor: Colors.red,
                icon: Icons.delete,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)) 
              ),
            ]
          ),
          child: GestureDetector(
            onTap: () => onTapCompleteHabit(),
            onLongPress: () => onLongPress(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                color: _isFlashingRed
                    ? Colors.red.withValues(alpha: 0.65)
                    : _isFlashingGreen
                        ? Colors.green.withValues(alpha: 0.65)
                        : AppColors.darkBackground,
                boxShadow: _isFlashingGreen || _isFlashingRed
                    ? [
                        BoxShadow(
                          color: _isFlashingGreen 
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.red.withValues(alpha: 0.3),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                    widget.itemHabit.icon,
                    width: 42,
                    height: 42,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.itemHabit.title,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '$counterToday de $dailyGoal completados',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white30,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  FittedBox(
                    child: Text(
                      _timeSinceStart,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 63, 243, 18),
                        fontWeight: FontWeight.w500
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onTapCompleteHabit() async {
    // Obtenemos la fecha de hoy en formato "YYYY-MM-DD"
    final String todayString = custom_date_utils.DateUtils.todayString();
    
    // Buscamos el indice del progreso correspondiente a hoy
    int indexProgress = widget.itemHabit.progress.indexWhere(
      (HabitProgress progress) => progress.date == todayString,
    );

    HabitProgress todayProgress = indexProgress != -1
        ? widget.itemHabit.progress[indexProgress]
        : HabitProgress(
            id: '',
            habitId: widget.itemHabit.id,
            date: todayString,
            dailyGoal: widget.itemHabit.dailyGoal,
            dailyCounter: 0,
          );

    // Verificar si ya se alcanzó la meta diaria usando el dailyGoal del HÁBITO, no del progreso
    if (indexProgress != -1 && todayProgress.dailyCounter >= widget.itemHabit.dailyGoal) {
      developer.log('Meta diaria ya alcanzada: ${todayProgress.dailyCounter} de ${widget.itemHabit.dailyGoal}');
      return; // Ya se alcanzó la meta diaria
    }

    try {
      if (indexProgress == -1) {
        // Crear un nuevo registro de progreso para hoy
        final newProgressId = await _supabaseService.createHabitProgress(
          habitId: widget.itemHabit.id,
          date: todayString,
          dailyGoal: widget.itemHabit.dailyGoal,
          dailyCounter: 1 // Se inicia con uno por que se acaba de completar
        );

        if (newProgressId != null) {
          final newProgress = HabitProgress(
            id: newProgressId,
            habitId: widget.itemHabit.id,
            date: todayString,
            dailyGoal: widget.itemHabit.dailyGoal,
            dailyCounter: 1
          );
          
          // Actualizar en el provider (esto sincroniza el estado global)
          widget.habitsProvider.updateHabitProgress(newProgress);
          
          developer.log('Nuevo progreso creado para hoy con ID: $newProgressId');
          
          // Mostrar animación de éxito DESPUÉS de guardar
          if (mounted) {
            setState(() {
              _isFlashingGreen = true;
            });
            await Future.delayed(AnimationConstants.fastAnimation);
            if (mounted) {
              setState(() {
                _isFlashingGreen = false;
              });
            }
          }
        } else {
          developer.log('Error: No se pudo crear el progreso');
        }
      } else {
        // Actualizar el progreso existente
        final int newCounter = todayProgress.dailyCounter + 1;
        
        await _supabaseService.updateHabitProgress(
          widget.itemHabit.id, 
          todayProgress.id, 
          newCounter
        );

        // Actualizar en el estado local del hábito
        final updatedProgress = todayProgress.copyWith(
          dailyCounter: newCounter
        );
        
        // Actualizar en el provider (sincroniza el estado global)
        widget.habitsProvider.updateHabitProgress(updatedProgress);

        developer.log('Progreso actualizado para hoy: $newCounter');
        
        // Mostrar animación de éxito DESPUÉS de guardar
        if (mounted) {
          setState(() {
            _isFlashingGreen = true;
          });
          await Future.delayed(AnimationConstants.fastAnimation);
          if (mounted) {
            setState(() {
              _isFlashingGreen = false;
            });
          }
        }
      }
    } catch (e) {
      developer.log('Error al actualizar el progreso: $e');
      // Mostrar feedback de error al usuario
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar el progreso'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void onLongPress() async {
    final String todayString = custom_date_utils.DateUtils.todayString();
    final int indexProgress = widget.itemHabit.progress.indexWhere(
      (HabitProgress progress) => progress.date == todayString,
    );

    if (indexProgress == -1) {
      developer.log('No hay progreso para hoy para decrementar.');
      return;
    }

    final HabitProgress todayProgress = widget.itemHabit.progress[indexProgress];

    if (todayProgress.dailyCounter <= 0) {
      developer.log('El contador diario ya está en 0, no se puede decrementar.');
      return;
    }

    final int newCounter = todayProgress.dailyCounter - 1;

    try {
      await _supabaseService.updateHabitProgress(
        widget.itemHabit.id,
        todayProgress.id,
        newCounter,
      );
      
      // Actualizar en el provider
      final updatedProgress = todayProgress.copyWith(dailyCounter: newCounter);
      widget.habitsProvider.updateHabitProgress(updatedProgress);
      
      developer.log('Progreso decrementado para hoy: $newCounter');
      
      // Mostrar animación DESPUÉS de guardar exitosamente
      if (mounted) {
        setState(() {
          _isFlashingRed = true;
        });
        await Future.delayed(AnimationConstants.fastAnimation);
        if (mounted) {
          setState(() {
            _isFlashingRed = false;
          });
        }
      }
    } catch (e) {
      developer.log('Error al decrementar el progreso: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al actualizar el progreso'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
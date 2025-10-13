import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habit_detail_screen/habit_detail_screen.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/delete_habit_dialog.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/item_habit/gesture_card.dart';
import 'package:find_your_mind/shared/domain/screen_type.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

class SlidableItem extends StatefulWidget {
  final HabitEntity habit;
  final HabitsProvider habitsProvider;
  final String timeSinceStart;
  final int counterToday;
  final int dailyGoal;
  final bool isFlashingRed;
  final bool isFlashingGreen;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const SlidableItem({
    super.key,
    required this.habit,
    required this.habitsProvider,
    required this.timeSinceStart,
    required this.counterToday,
    required this.dailyGoal,
    required this.isFlashingRed,
    required this.isFlashingGreen,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<SlidableItem> createState() => _SlidableItemState();
}

class _SlidableItemState extends State<SlidableItem> {
  

  @override
  Widget build(BuildContext context) {
    final screensProvider = Provider.of<ScreensProvider>(context, listen: false);

    return Slidable(
      key: ValueKey(widget.habit.id),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.35,
        children: [
          SlidableAction(
            onPressed: (context) {
              // Acción de editar
              widget.habitsProvider.changeTitle(widget.habit.title);
              screensProvider.setScreenWidget(
                HabitDetailScreen(habit: widget.habit), 
                ScreenType.habits
              );
            },
            backgroundColor: const Color.fromARGB(84, 80, 78, 78),
            foregroundColor: Colors.white,
            icon: Icons.info_outline_rounded,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))
          ),
          SlidableAction(
            onPressed: (context) async {              
              // Acción de eliminar - Mostrar diálogo de confirmación
              final confirmed = await DeleteHabitDialog.show(
                context, 
                widget.habit.title,
              );
                            
              if (!confirmed) {
                return;
              }
                            
              try {
                await widget.habitsProvider.deleteHabit(widget.habit.id);
                
                if (context.mounted) {
                  CustomToast.showToast(
                    context: context,
                    message: 'Hábito eliminado exitosamente',
                  );
                }
              } catch (e) {
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
      child: GestureCardHabitItem(
        habit: widget.habit,
        timeSinceStart: widget.timeSinceStart,
        counterToday: widget.counterToday,
        dailyGoal: widget.dailyGoal,
        isFlashingRed: widget.isFlashingRed,
        isFlashingGreen: widget.isFlashingGreen,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
      ),
    );
  }  
}
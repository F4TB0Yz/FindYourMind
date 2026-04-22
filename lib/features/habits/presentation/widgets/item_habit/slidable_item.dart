import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/delete_habit_dialog.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/item_habit/gesture_card.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SlidableItem extends StatefulWidget {
  final HabitEntity habit;
  final HabitsProvider habitsProvider;
  final String timeSinceStart;
  final int counterToday;
  final int dailyGoal;
  final bool isFlashingRed;
  final bool isFlashingGreen;
  final bool triggerCompletion;
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
    required this.triggerCompletion,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<SlidableItem> createState() => _SlidableItemState();
}

class _SlidableItemState extends State<SlidableItem> {
  

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Slidable(
      key: ValueKey(widget.habit.id),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        extentRatio: 0.40,
        children: [
          CustomSlidableAction(
            onPressed: (context) {
              // Acción de editar
              widget.habitsProvider.changeTitle(widget.habit.title);
              context.push('/habits/${widget.habit.id}', extra: widget.habit);
            },
            backgroundColor: Colors.transparent,
            foregroundColor: cs.primary,
            padding: EdgeInsets.zero,
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.edit2,
                size: 22,
                color: cs.primary,
              ),
            ),
          ),
          CustomSlidableAction(
            onPressed: (context) async {              
              // Acción de eliminar - Mostrar diálogo de confirmación
              final confirmed = await DeleteHabitDialog.show(
                context, 
                widget.habit.title,
              );
                            
              if (!confirmed) return;
                            
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
            backgroundColor: Colors.transparent,
            foregroundColor: cs.error,
            padding: EdgeInsets.zero,
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.only(left: 12, right: 6),
              decoration: BoxDecoration(
                color: cs.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.trash2,
                size: 22,
                color: cs.error,
              ),
            ),
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
        triggerCompletion: widget.triggerCompletion,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
      ),
    );
  }  
}
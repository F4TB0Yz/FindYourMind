import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habits_screen.dart';
import 'package:find_your_mind/features/notes/presentation/screens/notes_screen.dart';
import 'package:find_your_mind/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:find_your_mind/shared/domain/screen_type.dart';
import 'package:find_your_mind/shared/presentation/widgets/bottom_nav_bar/custom_item_bar.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomBottomBar extends StatelessWidget {
  const CustomBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    

    return Container(
      margin: const EdgeInsets.all(15),
      height: size.height * 0.1,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.darkBackground
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomItemBar(
              icon: LucideIcons.penTool,
              screen: NotesScreen(),
              screenType: ScreenType.notes,
            ),
            CustomItemBar(
              icon: LucideIcons.checkSquare,
              screen: TasksScreen(),
              screenType: ScreenType.tasks,
            ),
            CustomItemBar(
              icon: LucideIcons.clock,
              screen: HabitsScreen(),
              screenType: ScreenType.habits,  
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/screens/habits_screen.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/custom_button.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/statistics_habit.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/weekly_progress/weekly_progress.dart';
import 'package:find_your_mind/shared/domain/screen_type.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class DetailsView extends StatelessWidget {
  final HabitEntity habit;

  const DetailsView({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    final screensProvider = Provider.of<ScreensProvider>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),

        // Icono actual
        Center(
          child: SvgPicture.asset(
            habit.icon,
            width: 100,
            height: 100,
          ),
        ),
        const SizedBox(height: 10),

        const Center(
          child: Text(
            'Tú Semana',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.white60,
            ),
           ),
        ),

        const SizedBox(height: 10),

        WeeklyProgress(habit: habit),

        const SizedBox(height: 25),

        // Estadísticas
        StatisticsHabit(habit: habit),

        const SizedBox(height: 50),

        // Botones
        Row(
        children: [
          Expanded(
          child: CustomButton(
            title: 'Volver',
            onTap: () {
              screensProvider.setScreenWidget(const HabitsScreen(), ScreenType.habits);
            },
          ),
          )
        ],
        ),

        const SizedBox(height: 15),
      ],
    );
  }
}
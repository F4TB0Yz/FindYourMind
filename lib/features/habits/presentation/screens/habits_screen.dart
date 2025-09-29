import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/screens/new_habit_screen.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/container_border_habits.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/custom_button.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/item_habit.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/custom_border_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScreensProvider screensProvider = Provider.of<ScreensProvider>(context);
    final HabitsProvider habitsProvider = Provider.of<HabitsProvider>(context);

    return CustomBorderContainer(
      child: _buildHabitsView(screensProvider, habitsProvider),
    );
  }

  Widget _buildHabitsView(ScreensProvider screensProvider, HabitsProvider habitsProvider) { 
    return ContainerBorderHabits(
      child: Column(
        children: [
          // TabView
          Container(
            width: double.infinity,
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Color(0xFF2A2A2A)
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Todos'),
                Text('Recomendados'),
                Text('+'),
              ],
            ),
          ),
      
          const SizedBox(height: 15),
      
          // Lista de Habitos
          Expanded(
            child: ListView.builder(
              itemCount: habitsProvider.habits.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [                  
                    ItemHabit(
                      itemHabit: habitsProvider.habits[index],
                    ),

                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        
          const SizedBox(height: 10),
      
          CustomButton(
            title: 'AGREGAR NUEVO HABITO',
            onTap: () {
              screensProvider.setScreenWidget(const NewHabitScreen());
            },
          ),
      
          const SizedBox(height: 15)
        ],
      ),
    );
  }
}
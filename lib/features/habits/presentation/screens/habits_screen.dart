import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/screens/new_habit_screen.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/container_border_habits.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/custom_button.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/item_habit.dart';
import 'package:find_your_mind/shared/domain/screen_type.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/custom_border_container.dart';
import 'package:find_your_mind/shared/presentation/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    final HabitsProvider habitsProvider = Provider.of<HabitsProvider>(context, listen: false);
    if (mounted) habitsProvider.resetTitle();

    // Configurar listener para scroll infinito
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      // Cuando está al 80% del scroll, cargar más hábitos
      final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);
      habitsProvider.loadMoreHabits();
    }
  }

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
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
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
              color: AppColors.darkBackground
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
              controller: _scrollController,
              itemCount: habitsProvider.habits.length + (habitsProvider.isLoading && habitsProvider.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Mostrar indicador de carga al final si está cargando y hay más items
                if (index >= habitsProvider.habits.length) {
                  // Puedes cambiar entre estos estilos:
                  // return const CustomLoadingIndicator(text: 'Cargando más hábitos...'); // Estilo 1: Circular con texto
                  return const CustomLoadingDots(); // Estilo 2: Puntos animados (recomendado)
                  // return const CustomLoadingBar(text: 'Cargando...'); // Estilo 3: Barra de progreso
                }

                return TweenAnimationBuilder<double>(
                  key: ValueKey(habitsProvider.habits[index].id),
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 500)),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    children: [                  
                      ItemHabit(
                        itemHabit: habitsProvider.habits[index],
                        habitsProvider: habitsProvider,
                      ),

                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          ),
        
          const SizedBox(height: 10),
      
          CustomButton(
            title: 'AGREGAR NUEVO HABITO',
            onTap: () {
              screensProvider.setScreenWidget(const NewHabitScreen(), ScreenType.newHabit);
            },
          ),
      
          const SizedBox(height: 15)
        ],
      ),
    );
  }
}
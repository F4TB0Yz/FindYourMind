import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/screens/new_habit_screen.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/item_habit/item_habit.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/offline_mode_banner.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/sync_status_indicator.dart';
import 'package:find_your_mind/shared/domain/entities/screen_type.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:find_your_mind/shared/presentation/providers/sync_provider.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<HabitsProvider>(context, listen: false).resetTitle();
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      Provider.of<HabitsProvider>(context, listen: false).loadMoreHabits();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screensProvider = Provider.of<ScreensProvider>(context);
    final habitsProvider = Provider.of<HabitsProvider>(context);

    return Column(
      children: [
        // Header nativo: título + sync + botón +
        _HabitsHeader(
          onAddTap: () => screensProvider.setScreenWidget(
            const NewHabitScreen(),
            ScreenType.newHabit,
          ),
        ),

        // Divisor
        const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),

        // Filtros
        const _HabitsTabBar(),

        // Banner offline
        Consumer<SyncProvider>(
          builder: (context, syncProvider, _) => OfflineModeBanner(
            pendingChanges: syncProvider.pendingChangesCount,
            onSyncPressed: () async => syncProvider.syncWithServer(),
          ),
        ),

        // Lista
        Expanded(
          child: habitsProvider.isLoading && habitsProvider.habits.isEmpty
              ? const Center(
                  child: CustomLoadingIndicator(text: 'Cargando hábitos...'),
                )
              : ListView.builder(
                  controller: _scrollController,
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: habitsProvider.habits.length +
                      (habitsProvider.isLoading &&
                              habitsProvider.hasMore &&
                              habitsProvider.habits.isNotEmpty
                          ? 1
                          : 0),
                  itemBuilder: (context, index) {
                    if (index >= habitsProvider.habits.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CustomLoadingDots(),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: ItemHabit(
                        itemHabit: habitsProvider.habits[index],
                        habitsProvider: habitsProvider,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

/// Header de la pantalla: "Hábitos" con sync y botón de agregar.
class _HabitsHeader extends StatelessWidget {
  final VoidCallback onAddTap;

  const _HabitsHeader({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          const Text(
            'Hábitos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 8),
          const SyncStatusIndicator(),
          const Spacer(),
          GestureDetector(
            onTap: onAddTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppColors.textSecondary.withValues(alpha: 0.3), 
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.add,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tabs de filtro: Todos / Recomendados.
///
/// El tab activo tiene un underline de color primario.
class _HabitsTabBar extends StatelessWidget {
  const _HabitsTabBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Tab(label: 'Todos', isActive: true),
          const SizedBox(width: 20),
          _Tab(label: 'Recomendados', isActive: false),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isActive;

  const _Tab({required this.label, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 2,
            width: isActive ? 24 : 0,
            decoration: BoxDecoration(
              color: AppColors.accentText,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}
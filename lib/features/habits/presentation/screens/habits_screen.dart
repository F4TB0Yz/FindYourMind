import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/global_progress_bar.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/item_habit/item_habit.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/offline_mode_banner.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/sync_status_indicator.dart';
import 'package:find_your_mind/shared/presentation/providers/sync_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:find_your_mind/config/theme/app_text_styles.dart';

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
    return Column(
      children: [
        // Header nativo: título + sync
        const _HabitsHeader(),

        // Divisor
        const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),

        // Barra de Progreso Global (Dopamina persistente)
        Selector<HabitsProvider, double>(
          selector: (_, provider) => provider.globalTodayProgress,
          builder: (context, progress, _) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GlobalProgressBar(progress: progress),
          ),
        ),

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
          child: Consumer<HabitsProvider>(
            builder: (context, habitsProvider, _) {
              if (habitsProvider.isLoading && habitsProvider.habits.isEmpty) {
                return const Center(
                  child: CustomLoadingIndicator(text: 'Cargando hábitos...'),
                );
              }
              
              return ListView.builder(
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
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HabitsHeader extends StatelessWidget {
  const _HabitsHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      child: Row(
        children: [
          Text(
            'Hábitos',
            style: AppTextStyles.h3,
          ),
          const SizedBox(width: 8),
          const SyncStatusIndicator(),
        ],
      ),
    );
  }
}

class _HabitsTabBar extends StatelessWidget {
  const _HabitsTabBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const _Tab(label: 'Todos', isActive: true),
          const SizedBox(width: 20),
          const _Tab(label: 'Recomendados', isActive: false),
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
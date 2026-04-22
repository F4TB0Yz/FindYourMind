import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/global_progress_bar.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/item_habit/item_habit.dart';
import 'package:find_your_mind/features/habits/presentation/widgets/offline_mode_banner.dart';
import 'package:find_your_mind/shared/presentation/providers/sync_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/container_border_screens.dart';
import 'package:find_your_mind/shared/presentation/widgets/custom_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
    return ContainerBorderScreens(
      child: Column(
        children: [
          // Barra de Progreso Global (Dopamina persistente)
          Selector<HabitsProvider, double>(
            selector: (_, provider) => provider.globalTodayProgress,
            builder: (context, progress, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

                if (habitsProvider.habits.isEmpty) {
                  return const _EmptyHabitsState();
                }

                return ListView.builder(
                  controller: _scrollController,
                  clipBehavior: Clip.none,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount:
                      habitsProvider.habits.length +
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
      ),
    );
  }
}

// Filtros
class _HabitsTabBar extends StatelessWidget {
  const _HabitsTabBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _Tab(label: 'Todos', isActive: true),
          SizedBox(width: 20),
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
    final cs = Theme.of(context).colorScheme;

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
              color: isActive ? cs.onSurface : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 2,
            width: isActive ? 24 : 0,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHabitsState extends StatelessWidget {
  const _EmptyHabitsState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.sparkles,
            size: 80,
            color: cs.outline.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Comienza tu viaje',
            style: AppTextStyles.h2(context).copyWith(letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              'Aún no tienes hábitos registrados. Elige uno y empieza a construir tu mejor versión hoy.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium(
                context,
              ).copyWith(color: cs.onSurfaceVariant, height: 1.5),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () {
              context.push('/habits/new');
            },
            icon: const Icon(LucideIcons.plus, size: 18),
            label: const Text('Crear mi primer hábito'),
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary.withValues(alpha: 0.1),
              foregroundColor: cs.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: cs.primary.withValues(alpha: 0.4), width: 1),
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

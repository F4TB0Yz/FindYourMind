import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/features/profile/presentation/providers/profile_provider.dart';
import 'package:find_your_mind/features/profile/presentation/widgets/profile_header.dart';
import 'package:find_your_mind/features/profile/presentation/widgets/profile_stats/profile_stats_row.dart';
import 'package:find_your_mind/features/profile/presentation/widgets/profile_settings_content.dart';
import 'package:find_your_mind/features/profile/presentation/widgets/sign_out_dialog.dart';
import 'package:find_your_mind/shared/presentation/widgets/toast/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadUser();
    });
  }

  void _showComingSoon() {
    CustomToast.showToast(context: context, message: 'Próximamente');
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const SignOutDialog(),
    );
    if (confirmed == true && mounted) {
      await context.read<ProfileProvider>().signOut();
    }
  }

  static ({int bestStreak, int habitCount, int avgCompletion}) _computeStats(
    List<HabitEntity> habits,
  ) {
    if (habits.isEmpty) {
      return (bestStreak: 0, habitCount: 0, avgCompletion: 0);
    }

    final bestStreak = habits.fold<int>(
      0,
      (max, h) => h.longestStreak > max ? h.longestStreak : max,
    );

    final avgCompletion =
        (habits.fold<double>(0, (sum, h) => sum + h.completionRate) /
                habits.length)
            .round();

    return (
      bestStreak: bestStreak,
      habitCount: habits.length,
      avgCompletion: avgCompletion,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        context.select<ProfileProvider, bool>((p) => p.isLoading);
    final error = context.select<ProfileProvider, String?>((p) => p.error);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => context.read<ProfileProvider>().loadUser(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    final currentUser =
        context.select<ProfileProvider, UserEntity?>((p) => p.currentUser);

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            ProfileHeader(user: currentUser),
            const SizedBox(height: 16),
            Selector<HabitsProvider, ({int bestStreak, int count, int avg})>(
              selector: (_, p) {
                final stats = _computeStats(p.habits);
                return (
                  bestStreak: stats.bestStreak,
                  count: stats.habitCount,
                  avg: stats.avgCompletion,
                );
              },
              builder: (_, stats, _) => ProfileStatsRow(
                bestStreak: stats.bestStreak,
                habitCount: stats.count,
                avgCompletion: stats.avg,
              ),
            ),
            const SizedBox(height: 16),
            ProfileSettingsContent(
              onComingSoon: _showComingSoon,
              onSignOut: _confirmSignOut,
            ),
          ],
        ),
      ),
    );
  }
}

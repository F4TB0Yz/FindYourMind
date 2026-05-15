import 'package:find_your_mind/features/profile/presentation/widgets/profile_stats/stat_item.dart';
import 'package:find_your_mind/features/profile/presentation/widgets/profile_stats/vertical_divider.dart';
import 'package:flutter/material.dart';

class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    super.key,
    required this.bestStreak,
    required this.habitCount,
    required this.avgCompletion,
  });

  final int bestStreak;
  final int habitCount;
  final int avgCompletion;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dividerColor = cs.outlineVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              StatItem(value: '$bestStreak', label: 'MEJOR RACHA'),
              StatVerticalDivider(color: dividerColor),
              StatItem(value: '$habitCount', label: 'HÁBITOS'),
              StatVerticalDivider(color: dividerColor),
              StatItem(value: '$avgCompletion%', label: 'CUMPLIMIENTO'),
            ],
          ),
        ),
      ),
    );
  }
}

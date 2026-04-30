import 'package:find_your_mind/config/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class SoonWidget extends StatelessWidget {
  final String nameFeature;

  const SoonWidget({super.key, required this.nameFeature});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cs.outlineVariant, width: 1.5),
            ),
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withValues(alpha: 0.12),
                    border: Border.all(
                      color: cs.primary.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: HugeIcon(
                    icon: HugeIcons.strokeRoundedClock01,
                    color: cs.primary,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 20),
                Text(nameFeature, style: AppTextStyles.h2(context)),
                const SizedBox(height: 8),
                Text(
                  'PRÓXIMAMENTE',
                  style: AppTextStyles.labelSmall(context).copyWith(
                    color: cs.primary,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

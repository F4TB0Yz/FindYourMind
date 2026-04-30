import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class CardHeader extends StatelessWidget {
  const CardHeader({
    required this.resolvedEmoji,
    required this.title,
    required this.description,
    required this.streakDays,
    required this.isExpanded,
    required this.emojiBoxColor,
    super.key,
  });

  final String resolvedEmoji;
  final String title;
  final String description;
  final int streakDays;
  final bool isExpanded;
  final Color emojiBoxColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: emojiBoxColor,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Center(
            child: Text(
              resolvedEmoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            vertical: 2,
            horizontal: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFF3C282),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Center(
            child: Text(
              '🔥 ${streakDays}d',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF92400d),
                  ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        AnimatedRotation(
          turns: isExpanded ? 0.5 : 0.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedArrowDown01,
            size: 20,
            color: Color.fromARGB(255, 131, 152, 159),
          ),
        ),
      ],
    );
  }
}

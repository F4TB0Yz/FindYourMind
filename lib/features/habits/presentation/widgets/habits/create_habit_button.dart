import 'dart:ui';

import 'package:find_your_mind/features/habits/presentation/widgets/habits/create_habit_sheet/create_habit_sheet.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class CreateHabitButton extends StatelessWidget {
  const CreateHabitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withValues(alpha: isDark ? 0.3 : 0.2),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          isScrollControlled: false,
          useSafeArea: false,
          useRootNavigator: true,
          showDragHandle: false,
          builder: (context) => RepaintBoundary(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF00495c).withValues(alpha: 0.8)
                        : const Color(0xFFF2F0CD).withValues(alpha: 0.8),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: const CreateHabitSheet(),
                ),
              ),
            ),
          ),
        );
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? const Color(0xFFecfeff).withValues(alpha: 0.12)
              : const Color(0xFF15B0B8).withValues(alpha: 0.28),
        ),
        child: Center(
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedAdd01,
            size: 20,
            color: isDark ? const Color(0xFF67e8f9) : const Color(0xFF155e75),
          ),
        ),
      ),
    );
  }
}

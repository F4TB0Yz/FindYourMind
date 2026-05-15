import 'package:find_your_mind/features/profile/presentation/widgets/profile_settings/profile_settings_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsItemTile extends StatelessWidget {
  const SettingsItemTile({super.key, required this.item});

  final ProfileSettingsItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final iconBg = isDark ? item.iconColor.withValues(alpha: 0.18) : item.iconBackground;
    final labelColor = item.isDestructive ? Colors.red.shade600 : cs.onSurface;

    return InkWell(
      onTap: item.onTap,
      highlightColor: cs.onSurface.withValues(alpha: 0.05),
      splashColor: cs.onSurface.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(
                item.icon,
                size: 20,
                color: item.isDestructive ? Colors.red.shade600 : item.iconColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
            if (item.subtitle != null) ...[
              const SizedBox(width: 8),
              Text(
                item.subtitle!,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
            if (item.trailing != null) ...[
              const SizedBox(width: 8),
              item.trailing!,
            ],
            if (item.showChevron && item.trailing == null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, size: 20, color: cs.onSurfaceVariant),
            ],
          ],
        ),
      ),
    );
  }
}

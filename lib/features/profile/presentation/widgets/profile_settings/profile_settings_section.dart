import 'package:find_your_mind/features/profile/presentation/widgets/profile_settings/profile_settings_item.dart';
import 'package:find_your_mind/features/profile/presentation/widgets/profile_settings/settings_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({super.key, this.title, required this.items});

  final String? title;
  final List<ProfileSettingsItem> items;

  static const _cardLight = Color(0xFFF5F5F3);
  static const _cardDark = Color(0xFF1C2930);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = cs.brightness == Brightness.dark;
    final cardColor = isDark ? _cardDark : _cardLight;
    final dividerColor = isDark
        ? const Color(0xFF243840)
        : const Color(0xFFE8E8E6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title!.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                SettingsItemTile(item: items[i]),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 0.5,
                    color: dividerColor,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

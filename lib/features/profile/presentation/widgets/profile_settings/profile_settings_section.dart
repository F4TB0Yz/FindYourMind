import 'package:find_your_mind/features/profile/presentation/widgets/profile_settings/profile_settings_item.dart';
import 'package:find_your_mind/features/profile/presentation/widgets/profile_settings/settings_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({super.key, this.title, required this.items});

  final String? title;
  final List<ProfileSettingsItem> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final dividerColor = cs.outlineVariant;

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
            color: cs.surfaceContainer,
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
                    indent: 68,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:find_your_mind/features/profile/presentation/widgets/profile_settings/profile_settings_section.dart';
import 'package:find_your_mind/features/profile/presentation/widgets/profile_settings/profile_settings_item.dart';
import 'package:find_your_mind/features/profile/presentation/widgets/profile_settings/pro_badge.dart';
import 'package:find_your_mind/features/profile/presentation/widgets/profile_settings/dark_mode_toggle.dart';
import 'package:flutter/material.dart';

class ProfileSettingsContent extends StatelessWidget {
  const ProfileSettingsContent({
    super.key,
    required this.onComingSoon,
    required this.onSignOut,
  });

  final VoidCallback onComingSoon;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg(Color light, Color dark) => isDark ? dark : light;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSettingsSection(
            title: 'Cuenta',
            items: [
              ProfileSettingsItem(
                icon: Icons.star_outline_rounded,
                iconBackground: bg(Colors.amber.shade100, Colors.amber.withValues(alpha: 0.18)),
                iconColor: Colors.amber.shade700,
                label: 'Plan',
                trailing: const ProBadge(),
                onTap: onComingSoon,
              ),
              ProfileSettingsItem(
                icon: Icons.person_outline_rounded,
                iconBackground: bg(Colors.lightBlue.shade100, Colors.lightBlue.withValues(alpha: 0.18)),
                iconColor: Colors.lightBlue.shade700,
                label: 'Editar perfil',
                onTap: onComingSoon,
              ),
              ProfileSettingsItem(
                icon: Icons.notifications_none_rounded,
                iconBackground: bg(Colors.purple.shade100, Colors.purple.withValues(alpha: 0.18)),
                iconColor: Colors.purple.shade700,
                label: 'Notificaciones',
                subtitle: 'Activadas',
                onTap: onComingSoon,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ProfileSettingsSection(
            title: 'Preferencias',
            items: [
              ProfileSettingsItem(
                icon: Icons.wb_sunny_outlined,
                iconBackground: bg(Colors.indigo.shade100, Colors.indigo.withValues(alpha: 0.18)),
                iconColor: Colors.indigo.shade700,
                label: 'Modo oscuro',
                trailing: const DarkModeToggle(),
                showChevron: false,
              ),
              ProfileSettingsItem(
                icon: Icons.calendar_month_outlined,
                iconBackground: bg(Colors.green.shade100, Colors.green.withValues(alpha: 0.18)),
                iconColor: Colors.green.shade700,
                label: 'Recordatorios',
                subtitle: '9:00 AM',
                onTap: onComingSoon,
              ),
              ProfileSettingsItem(
                icon: Icons.shield_outlined,
                iconBackground: bg(Colors.deepOrange.shade100, Colors.deepOrange.withValues(alpha: 0.18)),
                iconColor: Colors.deepOrange.shade700,
                label: 'Privacidad y datos',
                onTap: onComingSoon,
              ),
            ],
          ),
          const SizedBox(height: 24),
          ProfileSettingsSection(
            items: [
              ProfileSettingsItem(
                icon: Icons.logout_rounded,
                iconBackground: bg(Colors.red.shade100, Colors.red.withValues(alpha: 0.18)),
                iconColor: Colors.red.shade600,
                label: 'Cerrar sesión',
                isDestructive: true,
                showChevron: false,
                onTap: onSignOut,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:find_your_mind/config/theme/app_colors.dart';
import 'package:find_your_mind/features/auth/domain/entities/user_entity.dart';
import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    this.user,
    this.onSettingsTap,
    this.avatarSize = 80,
  });

  final UserEntity? user;
  final VoidCallback? onSettingsTap;
  final double avatarSize;
  static const List<String> _months = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];

  static String _displayName(UserEntity u) {
    if (u.displayName != null && u.displayName!.isNotEmpty) {
      return u.displayName!;
    }
    final prefix = u.email.split('@').first;
    if (prefix.isEmpty) return 'Usuario';
    return '${prefix[0].toUpperCase()}${prefix.substring(1)}';
  }

  static String _initial(UserEntity u) {
    final name = _displayName(u);
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  static String _username(UserEntity u) {
    return '@${u.email.split('@').first}';
  }

  static String _memberSince(UserEntity u) {
    final month = _months[u.createdAt.month - 1];
    return 'desde $month ${u.createdAt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-1.5, -1.2),
          radius: 1.1,
          colors: [
            const Color(0xFF3BBFB9),
            isDark ? const Color(0xFF072A3B) : const Color(0xFF4B696A),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(1.2, 1.3),
                  radius: 1,
                  colors: [Color(0x4D38B2AC), Colors.transparent],
                  stops: [0.2, 1.2],
                ),
              ),
            ),
          ),

          if (onSettingsTap != null)
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white70),
                onPressed: onSettingsTap,
              ),
            ),

          if (user != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 62, bottom: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: avatarSize,
                      height: avatarSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? AppColors.avatarDarkFill
                            : AppColors.avatarLightFill,
                        border: Border.all(
                          color: isDark
                              ? AppColors.avatarDarkBorder
                              : AppColors.avatarLightBorder,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _initial(user!),
                          style: TextStyle(
                            color: isDark
                                ? AppColors.avatarDarkIcon
                                : AppColors.avatarLightIcon,
                            fontSize: avatarSize * 0.4,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _displayName(user!),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_username(user!)} \u00B7 ${_memberSince(user!)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white60,
                          ),
                    ),
                  ],
                ),
              ),
            )
          else
            const SizedBox(
              width: double.infinity,
              height: 100,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white70),
              ),
            ),
        ],
      ),
    );
  }
}

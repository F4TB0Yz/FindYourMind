import 'package:find_your_mind/config/theme/app_colors.dart';
import 'package:find_your_mind/shared/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isProfileActive;

  const MainAppBar({super.key, this.isProfileActive = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 20.0, right: 20.0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ProfileButton(isProfileActive: isProfileActive),

            // Icono de tema
            const ThemeToggleButton(),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);
}

class ProfileButton extends StatefulWidget {
  final bool isProfileActive;

  const ProfileButton({super.key, required this.isProfileActive});

  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      reverseDuration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse().then((_) {
      if (mounted && !widget.isProfileActive) {
        context.go('/profile');
      }
    });
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Borde externo
            border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
          ),
          child: Center(
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isProfileActive
                    ? const Color(0xFF06B6D4).withValues(alpha: 0.5)
                    : (isDark
                          ? AppColors.avatarDarkFill.withValues(alpha: 0.7)
                          : AppColors.avatarLightFill),
                // Borde interno
                border: Border.all(
                  color: widget.isProfileActive
                      ? const Color(0xFF06B6D4).withValues(alpha: 0.5)
                      : (isDark
                            ? AppColors.avatarDarkBorder.withValues(alpha: 0.7)
                            : AppColors.avatarLightBorder),
                  width: 1.5,
                ),
              ),
              child: Icon(
                LucideIcons.user,
                color: widget.isProfileActive
                    ? Colors.white
                    : (isDark
                          ? AppColors.avatarDarkIcon
                          : AppColors.avatarLightIcon),
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => themeProvider.toggleTheme(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark
              ? AppColors.themeToggleDarkFill
              : AppColors.themeToggleLightFill,
          border: Border.all(
            color: isDark
                ? Colors.transparent
                : colorScheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
                child: child,
              ),
            );
          },
          child: Icon(
            isDark ? LucideIcons.sun : LucideIcons.moon,
            key: ValueKey(isDark ? 'sun' : 'moon'),
            color: isDark ? AppColors.darkOnSurface : const Color(0xFF0e172a),
            size: 26,
          ),
        ),
      ),
    );
  }
}

import 'package:find_your_mind/config/theme/app_colors.dart';
import 'package:find_your_mind/shared/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isProfileActive;
  final int currentIndex;

  const MainAppBar({
    super.key,
    this.isProfileActive = false,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, left: 20.0, right: 20.0, bottom: 8.0),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ProfileButton(isProfileActive: isProfileActive),

            Expanded(
              child: _ScreenHeader(
                currentIndex: currentIndex,
                showHeader: _shouldShowHeader(context),
              ),
            ),

            // Icono de tema
            const ThemeToggleButton(),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(80);

  bool _shouldShowHeader(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    return location == '/habits' ||
        location == '/tasks' ||
        location == '/notes' ||
        location == '/profile';
  }
}

class _ScreenHeader extends StatelessWidget {
  final int currentIndex;
  final bool showHeader;

  const _ScreenHeader({required this.currentIndex, required this.showHeader});

  @override
  Widget build(BuildContext context) {
    if (!showHeader) {
      return const SizedBox.shrink();
    }

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final (title, subtitle) = switch (currentIndex) {
      0 => ('Hábitos', 'Construye consistencia diaria'),
      1 => ('Tareas', 'Organiza tu dia con intencion'),
      2 => ('Notas', 'Captura ideas y reflexiones'),
      3 => ('Perfil', 'Tu espacio personal'),
      _ => ('', ''),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.fraunces(
              textStyle: textTheme.titleLarge,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600
            ),
          ),
        ],
      ),
    );
  }
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
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                color: widget.isProfileActive
                    ? Colors.white
                    : (isDark
                          ? AppColors.avatarDarkIcon
                          : AppColors.avatarLightIcon),
                size: 16,
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
                : colorScheme.primary.withValues(alpha: 0.25),
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
          child: HugeIcon(
            icon: isDark
                ? HugeIcons.strokeRoundedSun01
                : HugeIcons.strokeRoundedMoon02,
            key: ValueKey(isDark ? 'sun' : 'moon'),
            color: isDark ? AppColors.darkOnSurface : const Color(0xFF0e172a),
            size: 26,
          ),
        ),
      ),
    );
  }
}

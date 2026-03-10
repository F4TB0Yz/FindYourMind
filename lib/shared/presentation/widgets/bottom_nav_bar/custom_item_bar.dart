import 'package:find_your_mind/shared/domain/entities/screen_type.dart';
import 'package:find_your_mind/shared/presentation/providers/screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Capa: Presentation → Widgets (Shared)
/// Ítem individual del bottom navigation bar.
/// Estado activo indicado por el color del ícono y un punto azul debajo.
class CustomItemBar extends StatelessWidget {
  final IconData icon;
  final Widget screen;
  final ScreenType screenType;
  final VoidCallback? onTap;

  const CustomItemBar({
    super.key,
    required this.icon,
    required this.screen,
    required this.screenType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screensProvider = Provider.of<ScreensProvider>(context);
    final bool isSelected =
        screensProvider.currentScreenType == screenType;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        screensProvider.setScreenWidget(screen, screenType);
        onTap?.call();
      },
      child: SizedBox(
        width: 64,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? const Color(0xFF58a6ff)
                  : const Color(0xFF8b949e),
            ),
            const SizedBox(height: 5),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF58a6ff)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
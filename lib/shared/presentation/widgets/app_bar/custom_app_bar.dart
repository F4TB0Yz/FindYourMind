import 'package:find_your_mind/shared/presentation/widgets/app_bar/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:find_your_mind/shared/presentation/providers/theme_provider.dart';

/// Capa: Presentation → Widgets (Shared)
/// AppBar de la aplicación. Logo a la izquierda, perfil a la derecha.
/// Separado del contenido por un borde inferior sutil.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkTheme = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      height: 100,
      decoration: const BoxDecoration(
        color: Color(0xFF0d1117),
        border: Border(
          bottom: BorderSide(color: Color(0xFF30363d), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image.asset(
            'assets/images/app_logo.png',
            height: 70,
            fit: BoxFit.contain,
          ),
          Profile(
            isDarkTheme: isDarkTheme,
          ),
        ],
      ),
    );
  }
}
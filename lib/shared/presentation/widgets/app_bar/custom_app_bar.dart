import 'package:find_your_mind/shared/presentation/widgets/app_bar/profile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:find_your_mind/shared/presentation/providers/theme_provider.dart';
import 'package:google_fonts/google_fonts.dart';

/// AppBar de la aplicación con estética Terminal.
/// Muestra el path dinámico basado en la navegación actual.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const CustomAppBar({super.key, this.title});

  @override
  Size get preferredSize => const Size.fromHeight(75);

  @override
  Widget build(BuildContext context) {

    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.5), width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Transform.scale(
                scale: 2.5,
                child: Image.asset(
                  'assets/images/app_logo.png',
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            Profile(),
          ],
        ),
      ),
    );
  }
}

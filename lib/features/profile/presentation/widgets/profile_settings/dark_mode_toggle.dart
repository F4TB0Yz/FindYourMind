import 'package:find_your_mind/shared/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.select<ThemeProvider, bool>(
      (p) => p.themeMode == ThemeMode.dark,
    );
    return Switch(
      value: isDark,
      onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
    );
  }
}

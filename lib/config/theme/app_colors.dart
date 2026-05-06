import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color darkSurface = Color(0xFF08151a);
  static const Color darkSurfaceContainer = Color(0xFF0E2730);
  static const Color darkOnSurface = Color(0xFFF1F5F9);
  static const Color darkOnSurfaceVariant = Color(0xFF94A3B8);
  static const Color darkOutlineVariant = Color(0xFF164E63);
  static const Color darkPrimary = Color(0xFF22D3EE);
  static const Color darkSecondary = Color(0xFFF97316);
  static const Color darkError = Color(0xFFEF4444);

  static const Color lightSurface = Color.fromARGB(255, 186, 232, 234);
  static const Color lightSurfaceContainer = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightOnSurfaceVariant = Color(0xFF475569);
  static const Color lightOutlineVariant = Color(0xFFa5f3fc);
  static const Color lightPrimary = Color(0xFF0891B2);
  static const Color lightSecondary = Color(0xFFF97316);
  static const Color lightError = Color(0xFFEF4444);

  static const Color avatarDarkFill = Color(0xFF155e75);
  static const Color avatarDarkBorder = Color(0xFF0e7390);
  static const Color avatarDarkIcon = Color(0xFFa5f3fc);
  static const Color avatarLightFill = Color(0xFFa5f3fc);
  static const Color avatarLightBorder = Color(0xFFffffff);
  static const Color avatarLightIcon = Color(0xFF0e7390);

  static const Color themeToggleDarkFill = Color(0xFF162125);
  static const Color themeToggleLightFill = Color(0xFFcff6fb);

  static Color oneTimeHabitCardColor(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF0D2027) : const Color(0xFFCBEBED);
  }

  static const List<Color> habitCardPalette = [
    Color(0xFFDFFECF), // Menta suave
    Color(0xFFD6F5FF), // Azul cielo
    Color(0xFFE8D8FF), // Lavanda
    Color(0xFFFFE4CC), // Melocotón
    Color(0xFFFFD9E6), // Rosa pastel
    Color(0xFFFFF7CC), // Amarillo crema
    Color(0xFFD1FAE5), // Esmeralda suave
    Color(0xFFCFFAFE), // Cian claro
    Color(0xFFFEE2E2), // Rojo suave
    Color(0xFFF5F3FF), // Violeta muy claro
  ];

  static Color habitCardColor(String habitId) {
    final index = habitId.codeUnits.fold<int>(0, (sum, code) => sum + code);
    return habitCardPalette[index % habitCardPalette.length];
  }

  static Color habitCardColorFromHex(String hex) {
    if (hex == 'random') return habitCardPalette[0]; // Fallback
    try {
      final String cleanHex = hex.replaceFirst('#', '').replaceFirst('0x', '');
      if (cleanHex.length == 6) {
        return Color(int.parse('FF$cleanHex', radix: 16));
      }
      return Color(int.parse(cleanHex, radix: 16));
    } catch (_) {
      return habitCardPalette[0];
    }
  }
}

abstract class HabitColors {
  static const List<Color> cyan = [Color(0xFF06B6D4), Color(0xFF0891B2)];
  static const List<Color> blue = [Color(0xFF3B82F6), Color(0xFF2563EB)];
  static const List<Color> purple = [Color(0xFFA855F7), Color(0xFF7C3AED)];
  static const List<Color> orange = [Color(0xFFF97316), Color(0xFFEA580C)];
  static const List<Color> rose = [Color(0xFFF43F5E), Color(0xFFE11D48)];
  static const List<Color> emerald = [Color(0xFF10B981), Color(0xFF059669)];

  static List<Color> getGradient(String id) {
    switch (id.toLowerCase()) {
      case 'cyan':
        return cyan;
      case 'blue':
        return blue;
      case 'purple':
        return purple;
      case 'orange':
        return orange;
      case 'rose':
        return rose;
      case 'emerald':
        return emerald;
      default:
        return cyan;
    }
  }
}
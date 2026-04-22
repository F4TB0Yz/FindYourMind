import 'package:flutter/material.dart';

/// Centraliza todas las constantes de color de la aplicación.
/// Úsalo para referenciar colores en widgets, temas y cualquier otro lugar.
abstract class AppColors {
  // ── Paleta Dark ──────────────────────────────────────────────────────────────
  static const Color darkSurface = Color(0xFF08151a);
  static const Color darkSurfaceContainer = Color(0xFF0E2730);
  static const Color darkOnSurface = Color(0xFFF1F5F9);
  static const Color darkOnSurfaceVariant = Color(0xFF94A3B8);
  static const Color darkOutlineVariant = Color(0xFF164E63);
  static const Color darkPrimary = Color(0xFF22D3EE);
  static const Color darkSecondary = Color(0xFFF97316);
  static const Color darkError = Color(0xFFEF4444);

  // ── Paleta Light ─────────────────────────────────────────────────────────────
  static const Color lightSurface = Color(0xFFedfeff);
  static const Color lightSurfaceContainer = Color(0xFFFFFFFF);
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightOnSurfaceVariant = Color(0xFF475569);
  static const Color lightOutlineVariant = Color(0xFFa5f3fc);
  static const Color lightPrimary = Color(0xFF0891B2);
  static const Color lightSecondary = Color(0xFFF97316);
  static const Color lightError = Color(0xFFEF4444);

  // ── Avatar (componente HabitsAppBar) ─────────────────────────────────────────
  /// Fondo del círculo interior del avatar en modo oscuro.
  static const Color avatarDarkFill = Color(0xFF155e75);

  /// Borde interior del avatar en modo oscuro.
  static const Color avatarDarkBorder = Color(0xFF0e7390);

  /// Color del ícono de usuario en modo oscuro (cyan claro).
  static const Color avatarDarkIcon = Color(0xFFa5f3fc);

  /// Fondo del círculo interior del avatar en modo claro.
  static const Color avatarLightFill = Color(0xFFa5f3fc);

  /// Borde interior del avatar en modo claro.
  static const Color avatarLightBorder = Color(0xFFffffff);

  /// Color del ícono de usuario en modo claro.
  static const Color avatarLightIcon = Color(0xFF0e7390);

  // ── ThemeToggleButton ────────────────────────────────────────────────────────
  /// Fondo del botón de cambio de tema en modo oscuro.
  static const Color themeToggleDarkFill = Color(0xFF162125);

  /// Fondo del botón de cambio de tema en modo claro.
  static const Color themeToggleLightFill = Color(0xFFf5feff);
}

/// Paletas de gradientes para los hábitos.
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

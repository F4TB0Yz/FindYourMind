import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

final double _borderRadius = 8.0;

// ── Paleta Dark (GitHub-inspired) ───────────────────────────────────────────
const _darkSurface = Color(0xFF161b22); // darkBackground
const _darkSurfaceLowest = Color(0xFF0d1117); // darkBackgroundAlt
const _darkOnSurface = Color(0xFFE6EDF3); // textPrimary
const _darkOnSurfaceVariant = Color(0xFF8B949E); // textSecondary
const _darkOutline = Color(0xFF484F58); // textMuted
const _darkOutlineVariant = Color(0xFF30363D); // borderSubtle
const _darkPrimary = Color(0xFF58A6FF); // accentText
const _darkTertiary = Color(0xFF3FB950); // successMuted
const _darkError = Color(0xFFF85149); // dangerMuted

// ── Paleta Light ─────────────────────────────────────────────────────────────
const _lightSurface = Colors.white;
const _lightSurfaceLowest = Color(0xFFF0F6FF);
const _lightOnSurface = Color(0xFF1F2328);
const _lightOnSurfaceVariant = Color(0xFF636C76);
const _lightOutline = Color(0xFF8C959F);
const _lightOutlineVariant = Color(0xFFD0D7DE);
const _lightPrimary = Color(0xFF0969DA);
const _lightTertiary = Color(0xFF1A7F37);
const _lightError = Color(0xFFCF222E);

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme),
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    // Primaries
    primary: _lightPrimary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDDF4FF),
    onPrimaryContainer: Color(0xFF0969DA),
    // Secondary
    secondary: Color(0xFF6E7781),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFEAF5FB),
    onSecondaryContainer: Color(0xFF1F2328),
    // Tertiary (success)
    tertiary: _lightTertiary,
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFDCFCE7),
    onTertiaryContainer: _lightTertiary,
    // Error (danger)
    error: _lightError,
    onError: Colors.white,
    errorContainer: Color(0xFFFFEBEB),
    onErrorContainer: _lightError,
    // Surface
    surface: _lightSurface,
    onSurface: _lightOnSurface,
    surfaceContainerLowest: _lightSurfaceLowest,
    // Outline
    outline: _lightOutline,
    outlineVariant: _lightOutlineVariant,
    // Misc
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFF1F2328),
    onInverseSurface: Colors.white,
    inversePrimary: Color(0xFF79C0FF),
    onSurfaceVariant: _lightOnSurfaceVariant,
  ),
  scaffoldBackgroundColor: const Color(0xFFF8FAFC),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      borderSide: const BorderSide(color: _lightOutlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      borderSide: const BorderSide(color: _lightPrimary, width: 2),
    ),
  ),
  dividerTheme: const DividerThemeData(color: _lightOutlineVariant),
  popupMenuTheme: PopupMenuThemeData(
    color: _lightSurface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: _lightOutlineVariant.withOpacity(0.3), width: 1),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    // Primaries
    primary: _darkPrimary,
    onPrimary: Color(0xFF0d1117),
    primaryContainer: Color(0xFF1C3A5E),
    onPrimaryContainer: _darkPrimary,
    // Secondary
    secondary: Color(0xFF8B949E),
    onSecondary: Color(0xFF0d1117),
    secondaryContainer: Color(0xFF21262D),
    onSecondaryContainer: Color(0xFFE6EDF3),
    // Tertiary (success)
    tertiary: _darkTertiary,
    onTertiary: Color(0xFF0d1117),
    tertiaryContainer: Color(0xFF0D2E14),
    onTertiaryContainer: _darkTertiary,
    // Error (danger)
    error: _darkError,
    onError: Color(0xFF0d1117),
    errorContainer: Color(0xFF3B0A0A),
    onErrorContainer: _darkError,
    // Surface
    surface: _darkSurface,
    onSurface: _darkOnSurface,
    surfaceContainerLowest: _darkSurfaceLowest,
    // Outline
    outline: _darkOutline,
    outlineVariant: _darkOutlineVariant,
    // Misc
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE6EDF3),
    onInverseSurface: Color(0xFF161b22),
    inversePrimary: Color(0xFF0969DA),
    onSurfaceVariant: _darkOnSurfaceVariant,
  ),
  scaffoldBackgroundColor: const Color(0xFF0d1117),
  cardTheme: CardThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      borderSide: const BorderSide(color: _darkOutlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      borderSide: const BorderSide(color: _darkPrimary, width: 2),
    ),
  ),
  dividerTheme: const DividerThemeData(color: _darkOutlineVariant),
  popupMenuTheme: PopupMenuThemeData(
    color: _darkSurface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: _darkOutlineVariant.withOpacity(0.3), width: 1),
    ),
  ),
);

class AppTheme {
  static ThemeData getAppTheme({required bool isDark}) {
    return isDark ? darkTheme : lightTheme;
  }
}

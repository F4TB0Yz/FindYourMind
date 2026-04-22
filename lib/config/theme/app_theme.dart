import 'package:find_your_mind/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const double _borderRadius = 8.0;

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.light().textTheme),
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.lightPrimary,
    onPrimary: Colors.white,
    secondary: AppColors.lightSecondary,
    onSecondary: Colors.white,
    error: AppColors.lightError,
    onError: Colors.white,
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightOnSurface,
    surfaceContainer: AppColors.lightSurfaceContainer,
    onSurfaceVariant: AppColors.lightOnSurfaceVariant,
    outlineVariant: AppColors.lightOutlineVariant,
  ),
  scaffoldBackgroundColor: AppColors.lightSurface,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.lightSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.plusJakartaSans(
      color: AppColors.lightOnSurface,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardThemeData(
    color: AppColors.lightSurfaceContainer,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadius * 2),
      side: const BorderSide(color: AppColors.lightOutlineVariant, width: 1),
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
      borderSide: const BorderSide(color: AppColors.lightOutlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
    ),
  ),
  dividerTheme: const DividerThemeData(color: AppColors.lightOutlineVariant),
  popupMenuTheme: PopupMenuThemeData(
    color: AppColors.lightSurface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: AppColors.lightOutlineVariant.withOpacity(0.3),
        width: 1,
      ),
    ),
  ),
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  textTheme: GoogleFonts.plusJakartaSansTextTheme(ThemeData.dark().textTheme),
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.darkPrimary,
    onPrimary: AppColors.darkSurface,
    secondary: AppColors.darkSecondary,
    onSecondary: AppColors.darkSurface,
    error: AppColors.darkError,
    onError: Colors.white,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkOnSurface,
    surfaceContainer: AppColors.darkSurfaceContainer,
    onSurfaceVariant: AppColors.darkOnSurfaceVariant,
    outlineVariant: AppColors.darkOutlineVariant,
  ),
  scaffoldBackgroundColor: AppColors.darkSurface,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: GoogleFonts.plusJakartaSans(
      color: AppColors.darkOnSurface,
      fontSize: 20,
      fontWeight: FontWeight.w600,
    ),
  ),
  cardTheme: CardThemeData(
    color: AppColors.darkSurfaceContainer,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_borderRadius * 2),
      side: const BorderSide(color: AppColors.darkOutlineVariant, width: 1),
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
      borderSide: const BorderSide(color: AppColors.darkOutlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_borderRadius),
      borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
    ),
  ),
  dividerTheme: const DividerThemeData(color: AppColors.darkOutlineVariant),
  popupMenuTheme: PopupMenuThemeData(
    color: AppColors.darkSurface,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: AppColors.darkOutlineVariant.withOpacity(0.3),
        width: 1,
      ),
    ),
  ),
);

class AppTheme {
  static ThemeData getAppTheme({required bool isDark}) {
    return isDark ? darkTheme : lightTheme;
  }
}

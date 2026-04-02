import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  textTheme: GoogleFonts.plusJakartaSansTextTheme(
    ThemeData.light().textTheme,
  ),
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF6366F1), // Indigo
    brightness: Brightness.light,
    surface: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  textTheme: GoogleFonts.plusJakartaSansTextTheme(
    ThemeData.dark().textTheme,
  ),
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF818CF8), // Indigo lighter
    brightness: Brightness.dark,
    surface: const Color(0xFF0F172A), // Slate 900
    onSurface: Colors.white,
  ),
  scaffoldBackgroundColor: const Color(0xFF020617), // Slate 950
);

class AppTheme {
  static ThemeData getAppTheme({required bool isDark}) {
    return isDark 
      ? darkTheme 
      : lightTheme;
  }
}
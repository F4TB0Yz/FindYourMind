import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'JosefinSans',
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.yellow,
    brightness: Brightness.light
  )
);

final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'JosefinSans',
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.dark
  )
);

class AppTheme {
  static ThemeData getAppTheme({required bool isDark}) {
    return isDark 
      ? darkTheme 
      : lightTheme;
  }
}
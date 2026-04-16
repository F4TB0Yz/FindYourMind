import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized Text Styles for FindYourMind.
/// Following an aggressive hierarchy for a premium, tech-precision feel.
///
/// Todos los estilos reciben [BuildContext] para leer el [ColorScheme] activo
/// y responder correctamente al cambio de tema claro/oscuro.
class AppTextStyles {
  // --- Plus Jakarta Sans (Main Font) ---

  static TextStyle h1(BuildContext ctx) => GoogleFonts.plusJakartaSans(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.0,
        color: Theme.of(ctx).colorScheme.onSurface,
      );

  static TextStyle h2(BuildContext ctx) => GoogleFonts.plusJakartaSans(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: Theme.of(ctx).colorScheme.onSurface,
      );

  static TextStyle h3(BuildContext ctx) => GoogleFonts.plusJakartaSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: Theme.of(ctx).colorScheme.onSurface,
      );

  static TextStyle titleLarge(BuildContext ctx) => GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(ctx).colorScheme.onSurface,
      );

  static TextStyle bodyMedium(BuildContext ctx) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(ctx).colorScheme.onSurface,
      );

  static TextStyle bodySmall(BuildContext ctx) => GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Theme.of(ctx).colorScheme.onSurfaceVariant,
      );

  static TextStyle labelSmall(BuildContext ctx) => GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Theme.of(ctx).colorScheme.outline,
        letterSpacing: 0.5,
      );

  // --- Monospaced (Counters / Real-time) ---

  static TextStyle counter(BuildContext ctx) => GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(ctx).colorScheme.primary,
      );

  static TextStyle timerSmall(BuildContext ctx) => GoogleFonts.plusJakartaSans(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Theme.of(ctx).colorScheme.outline,
      );

  static TextStyle achievementTitle(BuildContext ctx) =>
      GoogleFonts.plusJakartaSans(
        fontSize: 42,
        fontWeight: FontWeight.w900,
        letterSpacing: -1.5,
        color: Theme.of(ctx).colorScheme.onSurface,
      );
}

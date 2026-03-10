import 'package:flutter/material.dart';

/// Constantes de colores utilizadas en toda la aplicación.
class AppColors {
  AppColors._();

  // ── Fondos ──────────────────────────────────────────────────────────────────
  /// Superficie principal: cards, containers, filas de lista.
  static const Color darkBackground = Color(0xFF161b22);

  /// Superficie secundaria: fondos de pantalla, áreas de contenido.
  static const Color darkBackgroundAlt = Color(0xFF0d1117);

  // ── Texto ────────────────────────────────────────────────────────────────────
  /// Texto principal: títulos y valores destacados.
  static const Color textPrimary = Color(0xFFE6EDF3);

  /// Texto secundario: subtítulos, metadatos.
  static const Color textSecondary = Color(0xFF8B949E);

  /// Texto silenciado: labels, placeholders.
  static const Color textMuted = Color(0xFF484F58);

  // ── Colores de Estado ────────────────────────────────────────────────────────
  /// Verde apagado para éxito/completado (GitHub green).
  static const Color successMuted = Color(0xFF3FB950);

  /// Rojo apagado para error/fallido (GitHub red).
  static const Color dangerMuted = Color(0xFFF85149);

  /// Azul para valores numéricos destacados y acentos.
  static const Color accentText = Color(0xFF58A6FF);

  // ── Bordes ───────────────────────────────────────────────────────────────────
  /// Borde sutil para separar superficies sin llamar la atención.
  static const Color borderSubtle = Color(0xFF30363D);
}

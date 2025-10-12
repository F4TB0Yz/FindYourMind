/// Constantes de animación utilizadas en toda la aplicación
class AnimationConstants {
  // Prevenir instanciación
  AnimationConstants._();

  /// Duración estándar para animaciones rápidas (botones, transiciones)
  static const Duration fastAnimation = Duration(milliseconds: 150);

  /// Duración estándar para animaciones normales
  static const Duration normalAnimation = Duration(milliseconds: 300);

  /// Duración estándar para animaciones lentas
  static const Duration slowAnimation = Duration(milliseconds: 500);
}

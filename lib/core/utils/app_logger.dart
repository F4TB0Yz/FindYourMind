import 'package:logger/logger.dart';

/// Capa: Core → Utils
/// Wrapper centralizado del paquete [logger].
///
/// Uso:
/// ```dart
/// AppLogger.d('Mensaje de debug');        // Solo en debug/development
/// AppLogger.i('Inicialización completa'); // Eventos importantes
/// AppLogger.w('Situación anómala');       // Advertencias recuperables
/// AppLogger.e('Error crítico', error: e, stackTrace: st);
/// ```
///
/// En producción, el nivel efectivo es [Level.warning], por lo que los
/// mensajes DEBUG e INFO son ignorados automáticamente.
class AppLogger {
  AppLogger._(); // Constructor privado: clase de utilidades puras.

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 6,
      lineLength: 100,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  // ─── API pública ──────────────────────────────────────────────────────────

  /// DEBUG — Flujo normal y detalles de operaciones de rutina.
  /// Visible solo en modo debug.
  static void d(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// INFO — Eventos relevantes del sistema (inicialización, sesiones, etc.).
  static void i(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// WARNING — Situaciones anómalas pero recuperables (duplicados, retries...).
  static void w(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// ERROR — Fallos inesperados que requieren atención.
  static void e(dynamic message, {Object? error, StackTrace? stackTrace}) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }
}

/// Capa: Core → Utils
/// Validadores reutilizables para los formularios de la aplicación.
/// Todos los mensajes de error están centralizados aquí (sin hardcoding en UI).
/// Uso: pasar el método directamente como `validator` en un `TextFormField`.
class AppValidators {
  AppValidators._(); // Constructor privado: clase de utilidades puras.

  // ─── Correo electrónico ────────────────────────────────────────────────────

  /// Valida que el campo no esté vacío y tenga formato de correo válido.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El correo electrónico es obligatorio.';
    }
    final emailRegex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Ingresa un correo electrónico válido.';
    }
    return null;
  }

  // ─── Contraseña ────────────────────────────────────────────────────────────

  /// Valida que la contraseña no esté vacía y tenga al menos 6 caracteres.
  /// (Límite mínimo impuesto por Supabase Auth.)
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria.';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres.';
    }
    return null;
  }

  // ─── Campo genérico requerido ──────────────────────────────────────────────

  /// Valida que un campo de texto cualquiera no esté vacío.
  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio.';
    }
    return null;
  }
}

/// Capa: Presentation → Utils
/// Centraliza la traducción de errores técnicos de autenticación
/// a mensajes amigables para el usuario final.
String getAuthErrorMessage(String error, {bool isRegister = false}) {
  final errorLower = error.toLowerCase();

  if (errorLower.contains('invalid login credentials') ||
      errorLower.contains('invalid_credentials')) {
    return 'Correo o contraseña incorrectos';
  }

  if (errorLower.contains('user already registered') ||
      errorLower.contains('already exists') ||
      errorLower.contains('user_already_exists') ||
      errorLower.contains('already been registered')) {
    return 'Este correo ya está registrado. Por favor inicia sesión';
  }

  if (errorLower.contains('database error') ||
      errorLower.contains('unexpected_failure') ||
      errorLower.contains('statuscode: 500')) {
    return 'Error del servidor. Intenta más tarde';
  }

  if (errorLower.contains('email') && errorLower.contains('invalid')) {
    return 'El formato del correo no es válido';
  }

  if (errorLower.contains('password') &&
      (errorLower.contains('short') || errorLower.contains('weak'))) {
    return 'La contraseña debe tener al menos 6 caracteres';
  }

  if (errorLower.contains('network') || errorLower.contains('connection')) {
    return 'Error de conexión. Verifica tu internet';
  }

  if (errorLower.contains('too many requests')) {
    return 'Demasiados intentos. Intenta más tarde';
  }

  if (errorLower.contains('user not found')) {
    return 'Usuario no encontrado';
  }

  if (errorLower.contains('timeout')) {
    return 'La solicitud tardó demasiado. Intenta nuevamente';
  }

  if (errorLower.contains('oauth') ||
      errorLower.contains('validation_failed') ||
      errorLower.contains('missing oauth secret')) {
    return 'Google no está configurado. Contacta al administrador';
  }

  return isRegister
      ? 'Error al crear la cuenta. Intenta nuevamente'
      : 'Error al iniciar sesión. Intenta nuevamente';
}

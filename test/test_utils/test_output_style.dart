import 'dart:io';

const String _ansiMagenta = '\x1B[35m';
const String _ansiReset = '\x1B[0m';

bool _shouldColorize() {
  final env = Platform.environment;

  if (env.containsKey('NO_COLOR')) return false;
  if (env['TERM'] == 'dumb') return false;

  final forceColor = env['FORCE_COLOR'];
  if (forceColor != null && forceColor != '0') return true;

  // Many CI systems don't expose a real TTY, but still render ANSI colors.
  if (env.containsKey('CI')) return true;

  return stdout.supportsAnsiEscapes;
}

/// Wraps a label with ANSI magenta when supported.
///
/// Used in `test(...)` / `group(...)` descriptions to visually differentiate
/// translated messages in terminal/CI logs.
String label(String text) {
  if (!_shouldColorize()) return text;
  return '$_ansiMagenta$text$_ansiReset';
}

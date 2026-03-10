import 'package:flutter/material.dart';

/// Capa: Presentation → Widgets
/// Botón primario de autenticación (color sólido, ancho completo).
/// Sin gradientes, sin sombras dramáticas, sin transform en press.
class AuthPrimaryButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final bool isLoading;

  const AuthPrimaryButton({
    super.key,
    required this.child,
    this.onTap,
    this.isLoading = false,
  });

  @override
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onTap,
      child: AnimatedOpacity(
        opacity: _isPressed ? 0.75 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF58a6ff),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF58a6ff),
              width: 1,
            ),
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : widget.child,
          ),
        ),
      ),
    );
  }
}

/// Botón secundario de autenticación (borde sutil, fondo oscuro).
/// Usado para acciones alternativas como "Continuar con Google".
class AuthSecondaryButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const AuthSecondaryButton({
    super.key,
    required this.child,
    this.onTap,
  });

  @override
  State<AuthSecondaryButton> createState() => _AuthSecondaryButtonState();
}

class _AuthSecondaryButtonState extends State<AuthSecondaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        opacity: _isPressed ? 0.7 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: double.infinity,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF161b22),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF30363d),
              width: 1,
            ),
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

/// Capa: Presentation → Widgets
/// Campo de texto reutilizable para los formularios de autenticación.
/// Incluye soporte para contraseña (toggle show/hide) y navegación por teclado.
class AuthInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool isPassword;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  bool _obscureText = true;

  void _toggleVisibility() {
    setState(() => _obscureText = !_obscureText);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Color(0xFFc9d1d9),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 44,
          child: TextField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            textInputAction: widget.textInputAction,
            obscureText: widget.isPassword && _obscureText,
            style: const TextStyle(
              color: Color(0xFFc9d1d9),
              fontSize: 14,
            ),
            onSubmitted: (_) => widget.onSubmitted?.call(),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF161b22),
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color(0xFF8b949e),
                fontSize: 14,
              ),
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF8b949e),
                        size: 18,
                      ),
                      onPressed: _toggleVisibility,
                      splashRadius: 16,
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: Color(0xFF30363d),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: Color(0xFF30363d),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(
                  color: Color(0xFF58a6ff),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
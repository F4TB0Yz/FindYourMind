import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Capa: Presentation → Widgets
/// Campo de texto reutilizable para los formularios de autenticación.
/// Usa [TextFormField] internamente para integrarse con [Form] y [GlobalKey<FormState>].
/// Incluye soporte para:
///   - Validación declarativa vía [validator].
///   - Campo de contraseña con toggle show/hide.
///   - Navegación por teclado mediante [textInputAction] y [onSubmitted].
class AuthInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool isPassword;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;

  /// Función de validación compatible con [Form]. Si retorna una cadena,
  /// se muestra como mensaje de error debajo del campo.
  final String? Function(String?)? validator;

  const AuthInputField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.isPassword = false,
    this.focusNode,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.validator,
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
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textInputAction: widget.textInputAction,
          obscureText: widget.isPassword && _obscureText,
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(
            color: Color(0xFFc9d1d9),
            fontSize: 14,
          ),
          onFieldSubmitted: (_) => widget.onSubmitted?.call(),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF161b22),
            hintText: widget.hint,
            hintStyle: const TextStyle(
              color: Color(0xFF8b949e),
              fontSize: 14,
            ),
            // Mensaje de error alineado debajo del campo, sin romper el layout.
            errorStyle: const TextStyle(
              color: Color(0xFFf85149),
              fontSize: 11,
              height: 1.4,
            ),
            errorMaxLines: 2,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: HugeIcon(
                      icon: _obscureText
                          ? HugeIcons.strokeRoundedViewOffSlash
                          : HugeIcons.strokeRoundedView,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: Color(0xFFf85149),
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: Color(0xFFf85149),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
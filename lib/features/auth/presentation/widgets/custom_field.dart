import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class AuthInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool isPassword;
  final FocusNode? focusNode;
  final TextInputAction textInputAction;
  final VoidCallback? onSubmitted;
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
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: textTheme.bodyMedium?.copyWith(
            color: cs.onSurface,
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
          style: textTheme.bodyMedium?.copyWith(
            color: cs.onSurface,
            fontSize: 14,
          ),
          onFieldSubmitted: (_) => widget.onSubmitted?.call(),
          decoration: InputDecoration(
            filled: true,
            fillColor: cs.surfaceContainer,
            hintText: widget.hint,
            hintStyle: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 14,
            ),
            errorStyle: TextStyle(
              color: cs.error,
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
                      color: cs.onSurfaceVariant,
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
            border: _outlineBorder(cs.outlineVariant),
            enabledBorder: _outlineBorder(cs.outlineVariant),
            focusedBorder: _outlineBorder(cs.primary, width: 2),
            errorBorder: _outlineBorder(cs.error),
            focusedErrorBorder: _outlineBorder(cs.error, width: 1.5),
          ),
        ),
      ],
    );
  }

  static OutlineInputBorder _outlineBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

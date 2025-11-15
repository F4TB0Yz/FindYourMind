import 'package:flutter/material.dart';

class CustomAuthButton extends StatefulWidget {
  final Widget child;
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool isPrimary;
  final Color? customColor;

  const CustomAuthButton({
    super.key, 
    required this.child,
    this.width = 100,
    this.height = 50,
    this.onTap,
    this.isPrimary = false,
    this.customColor,
  });

  @override
  State<CustomAuthButton> createState() => _CustomAuthButtonState();
}

class _CustomAuthButtonState extends State<CustomAuthButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final Color buttonColor = widget.customColor ?? 
      (widget.isPrimary 
        ? const Color(0xFF4A90E2) 
        : const Color(0xFF191919));
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: widget.isPrimary
            ? LinearGradient(
                colors: [
                  buttonColor,
                  buttonColor.withBlue((buttonColor.blue * 0.8).toInt()),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
          color: widget.isPrimary ? null : buttonColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: _isPressed 
            ? [
                BoxShadow(
                  color: buttonColor.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: buttonColor.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
          border: Border.all(
            color: widget.isPrimary 
              ? Colors.white.withOpacity(0.1)
              : Colors.white.withOpacity(0.05),
            width: 1,
          ),
        ),
        transform: Matrix4.translationValues(
          0, 
          _isPressed ? 2 : 0, 
          0,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: widget.onTap,
            splashColor: Colors.white.withOpacity(0.1),
            highlightColor: Colors.white.withOpacity(0.05),
            child: Center(
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
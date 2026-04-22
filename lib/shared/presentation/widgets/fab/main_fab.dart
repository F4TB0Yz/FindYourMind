import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class MainFab extends StatefulWidget {
  final VoidCallback? onPressed;

  const MainFab({super.key, this.onPressed});

  @override
  State<MainFab> createState() => _MainFabState();
}

class _MainFabState extends State<MainFab> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 150),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInBack, // Efecto bounce elegante al regresar
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handlePress() async {
    if (widget.onPressed == null) return;

    // Ejecutar animación de ida y vuelta
    await _controller.forward();
    await _controller.reverse();

    // Ejecutar funcionalidad original
    widget.onPressed!();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, 10), // Lo bajamos un poco
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SizedBox(
            width: 72,
            height: 72,
            child: FloatingActionButton(
              onPressed: _handlePress,
              elevation: 0,
              highlightElevation: 0,
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF3B82F6), // Blue 500
                      Color(0xFF06B6D4), // Cyan 500
                    ],
                  ),
                ),
                child: const Icon(
                  LucideIcons.plus,
                  color: Colors.white,
                  size: 40, // Icono más grande
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

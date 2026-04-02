import 'dart:math' as math;
import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

/// Un Floating Action Button expandible para "Quick Actions".
/// Implementa la Ley de Fitts al estar centrado y ser fácilmente accesible.
/// Corregido: Expande HACIA ARRIBA en un arco de 210 a 330 grados.
class ExpandableFab extends StatefulWidget {
  const ExpandableFab({
    super.key,
    this.initialOpen,
    required this.distance,
    required this.children,
  });

  final bool? initialOpen;
  final double distance;
  final List<Widget> children;

  @override
  State<ExpandableFab> createState() => _ExpandableFabState();
}

class _ExpandableFabState extends State<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
      value: _open ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // IMPORTANTE: Eliminamos SizedBox.expand para evitar "bugs de fondo"
    // El FAB solo debe ocupar el espacio necesario para el botón central cuando está cerrado.
    return SizedBox(
      width: 56,
      height: 56,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          _buildTapToCloseFab(),
          ..._buildExpandingActionButtons(),
          _buildTapToOpenFab(),
        ],
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _open ? 56 : 0,
      height: _open ? 56 : 0,
      child: Center(
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          color: AppColors.darkBackground,
          child: InkWell(
            onTap: _toggle,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.close,
                color: Color(0xFF6366F1), // Indigo accent
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildExpandingActionButtons() {
    final children = <Widget>[];
    final count = widget.children.length;
    // Arco superior en radianes (de ~40 grados a ~140 grados)
    // En matemáticas: 0 = Derecha, PI/2 (1.57) = ARRIBA, PI = Izquierda.
    final startAngle = 0.7; // ~40 grados
    final endAngle = 2.4;   // ~140 grados
    final step = count > 1 ? (endAngle - startAngle) / (count - 1) : 0.0;
    
    for (var i = 0; i < count; i++) {
      final angle = startAngle + (i * step);
      children.add(
        _ExpandingActionButton(
          directionInRadians: angle,
          maxDistance: widget.distance,
          progress: _expandAnimation,
          child: widget.children[i],
        ),
      );
    }
    return children;
  }

  Widget _buildTapToOpenFab() {
    return IgnorePointer(
      ignoring: _open,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        transformAlignment: Alignment.center,
        transform: Matrix4.diagonal3Values(
          _open ? 0.0 : 1.0,
          _open ? 0.0 : 1.0,
          1.0,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1), // Indigo
                Color(0xFF4F46E5), // Indigo Darker
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: _toggle,
            elevation: 0,
            backgroundColor: Colors.transparent,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 30),
          ),
        ),
      ),
    );
  }
}

@immutable
class _ExpandingActionButton extends StatelessWidget {
  const _ExpandingActionButton({
    required this.directionInRadians,
    required this.maxDistance,
    required this.progress,
    required this.child,
  });

  final double directionInRadians;
  final double maxDistance;
  final Animation<double> progress;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        // En matemáticas estándar: 
        // dx = cos(angle), dy = sin(angle)
        // dx positivo es Derecha, dy positivo es ARRIBA.
        final dx = math.cos(directionInRadians) * progress.value * maxDistance;
        final dy = math.sin(directionInRadians) * progress.value * maxDistance;
        
        return Positioned(
          // Centrado horizontal (28 es la mitad de 56)
          // El child tiene un tamaño intrínseco, pero el ActionButton suele ser 40-48px.
          // Si el child es ~48px, restamos 24 para centrarlo en el punto exacto.
          left: 28 - 24 + dx,
          bottom: dy,
          child: Transform.rotate(
            angle: (1.0 - progress.value) * math.pi / 2,
            child: child!,
          ),
        );
      },
      child: FadeTransition(
        opacity: progress,
        child: child,
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.color,
  });

  final VoidCallback? onPressed;
  final Widget icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: color?.withOpacity(0.9) ?? AppColors.darkBackground,
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
          color: Colors.white,
          iconSize: 22,
        ),
      ),
    );
  }
}

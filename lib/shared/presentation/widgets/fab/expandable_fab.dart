import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Un Floating Action Button expandible para "Quick Actions".
/// Implementa la Ley de Fitts al estar centrado y ser fácilmente accesible.
/// Utiliza un [Overlay] para que los botones expandidos no afecten el layout
/// del Scaffold y mantengan su capacidad de recibir toques (hit-testing).
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

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen ?? false;
    _controller = AnimationController(
        value: _open ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        vsync: this);

    _expandAnimation = CurvedAnimation(
      curve: Curves.fastOutSlowIn,
      reverseCurve: Curves.easeOutQuad,
      parent: _controller,
    );

    if (_open) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _toggle());
    }
  }

  @override
  void dispose() {
    _hideOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _open = !_open;
      if (_open) {
        _showOverlay();
        _controller.forward();
      } else {
        _controller.reverse().then((_) {
          if (!mounted) return;
          _hideOverlay();
        });
      }
    });
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Container(color: Colors.transparent),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: const Offset(0, 0),
            child: SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: _buildExpandingActionButtons(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            _buildTapToCloseFab(),
            _buildTapToOpenFab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTapToCloseFab() {
    final cs = Theme.of(context).colorScheme;

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
          color: cs.surface,
          child: InkWell(
            onTap: _toggle,
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.close,
                color: Color(0xFF6366F1), // Indigo accent — intencional, no semántico
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
    const startAngle = 0.7;
    const endAngle = 2.4;
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
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6366F1), // Indigo
                Color(0xFF4F46E5), // Indigo Darker
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x4D6366F1),
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
        final dx = math.cos(directionInRadians) * progress.value * maxDistance;
        final dy = math.sin(directionInRadians) * progress.value * maxDistance;

        return Positioned(
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
    final cs = Theme.of(context).colorScheme;

    return Material(
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      color: color?.withValues(alpha: 0.9) ?? cs.surface,
      elevation: 6,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
          color: cs.onSurface,
          iconSize: 22,
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

class Particle {
  double x, y;
  double vx, vy;
  double size;
  Color color;
  double opacity = 1.0;

  Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.size,
    required this.color,
  });

  void update() {
    x += vx;
    y += vy;
    vy += 0.2; // Gravity
    opacity -= 0.03;
    if (opacity < 0) opacity = 0;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      if (particle.opacity <= 0) continue;
      final paint = Paint()..color = particle.color.withOpacity(particle.opacity);
      canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ParticleExplosion extends StatefulWidget {
  final Widget child;
  final bool trigger;
  final Color color;

  const ParticleExplosion({
    super.key,
    required this.child,
    required this.trigger,
    this.color = const Color(0xFF3FB950), // successMuted
  });

  @override
  State<ParticleExplosion> createState() => _ParticleExplosionState();
}

class _ParticleExplosionState extends State<ParticleExplosion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<Particle> _particles = [];
  final math.Random _random = math.Random();
  Size _size = Size.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..addListener(() {
        if (_particles.isNotEmpty) {
          setState(() {
            for (final p in _particles) {
              p.update();
            }
            _particles.removeWhere((p) => p.opacity <= 0);
          });
        }
      });
  }

  @override
  void didUpdateWidget(ParticleExplosion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.trigger && !oldWidget.trigger) {
      _burst();
    }
  }

  void _burst() {
    final centerX = _size.width / 2;
    final centerY = _size.height / 2;
    
    _particles.clear();
    for (var i = 0; i < 30; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = _random.nextDouble() * 6 + 3;
      _particles.add(
        Particle(
          x: centerX,
          y: centerY,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed,
          size: _random.nextDouble() * 2.5 + 1,
          color: widget.color.withOpacity(0.8 + _random.nextDouble() * 0.2),
        ),
      );
    }
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = Size(constraints.maxWidth, constraints.maxHeight);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            widget.child,
            if (_particles.isNotEmpty)
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: ParticlePainter(_particles),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

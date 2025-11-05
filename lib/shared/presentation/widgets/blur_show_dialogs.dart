import 'dart:ui';

import 'package:flutter/material.dart';

class BlurShowDialogs extends StatelessWidget {
  final Offset position;
  final Size size;
  final bool center;
  final Widget child;

  const BlurShowDialogs({
    super.key,
    required this.position,
    required this.size,
    this.center = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blur Effect
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 3),
            child: Container(
              color: Colors.black.withValues(alpha: 0.1),
            ),
          ),
        ),

        // Gesture Detector to close dialog on tap outside
        Positioned.fill(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            behavior: HitTestBehavior.translucent,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),

        // Dialog Content
        center
          ? Center(child: child)
          : Positioned(
              left: position.dx,
              top: position.dy + size.height + 5,
              child: child,
            ),
      ],
    );
  }
}
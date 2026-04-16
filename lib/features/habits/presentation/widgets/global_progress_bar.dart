import 'package:flutter/material.dart';

class GlobalProgressBar extends StatefulWidget {
  final double progress;

  const GlobalProgressBar({super.key, required this.progress});

  @override
  State<GlobalProgressBar> createState() => _GlobalProgressBarState();
}

class _GlobalProgressBarState extends State<GlobalProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      height: 4,
      decoration: BoxDecoration(
        color: cs.outlineVariant,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: widget.progress.clamp(0.0, 1.0),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    cs.primary,
                    cs.tertiary,
                    cs.primary,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                  transform: GradientRotation(_controller.value * 2 * 3.1415),
                ),
                boxShadow: [
                  BoxShadow(
                    color: cs.tertiary.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

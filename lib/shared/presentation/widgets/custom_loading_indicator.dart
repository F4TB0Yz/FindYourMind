import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

/// Indicador de carga personalizado para listas
class CustomLoadingIndicator extends StatelessWidget {
  final String? text;
  final Color? color;
  
  const CustomLoadingIndicator({
    super.key,
    this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Indicador circular con colores del tema
            SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  color ?? Colors.amber.shade400,
                ),
                backgroundColor: AppColors.darkBackground,
              ),
            ),
            if (text != null) ...[
              const SizedBox(height: 12),
              Text(
                text!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontFamily: 'JosefinSans',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Indicador de carga con animación de puntos
/// Más discreto y moderno
class CustomLoadingDots extends StatefulWidget {
  final Color? color;
  final double size;
  
  const CustomLoadingDots({
    super.key,
    this.color,
    this.size = 8.0,
  });

  @override
  State<CustomLoadingDots> createState() => _CustomLoadingDotsState();
}

class _CustomLoadingDotsState extends State<CustomLoadingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dotColor = widget.color ?? Colors.amber.shade400;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final delay = index * 0.2;
                final animValue = (_controller.value - delay).clamp(0.0, 1.0);
                final scale = 0.7 + (0.3 * (1 - (animValue * 2 - 1).abs()));
                
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: dotColor.withValues(alpha: 0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

/// Indicador de carga con barra de progreso lineal
class CustomLoadingBar extends StatelessWidget {
  final String? text;
  final Color? color;
  
  const CustomLoadingBar({
    super.key,
    this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                color ?? Colors.amber.shade400,
              ),
              backgroundColor: AppColors.darkBackground,
            ),
          ),
          if (text != null) ...[
            const SizedBox(height: 8),
            Text(
              text!,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontFamily: 'JosefinSans',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

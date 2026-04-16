import 'package:find_your_mind/shared/presentation/widgets/custom_border_container.dart';
import 'package:flutter/material.dart';

/// Un contenedor que aplica el borde estético de la aplicación.
/// Ya no maneja títulos hardcodeados — el layout ahora es más limpio.
class ContainerBorderScreens extends StatelessWidget {
  final Widget child;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ContainerBorderScreens({
    super.key,
    required this.child,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return CustomBorderContainer(
      margin: margin,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          Expanded(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(0),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
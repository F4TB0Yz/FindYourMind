import 'package:flutter/material.dart';

/// Layout base para las pantallas de funcionalidades.
/// Maneja automáticamente el patrón de contenedor con borde y scroll opcional.
class FeatureLayout extends StatelessWidget {
  /// El contenido principal de la pantalla.
  final Widget child;

  /// Si es true, el contenido se envolverá en un [SingleChildScrollView].
  final bool scrollable;

  /// Padding opcional para el contenido principal.
  final EdgeInsetsGeometry? padding;

  const FeatureLayout({
    super.key,
    required this.child,
    this.scrollable = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Área de contenido
        Expanded(
          child: scrollable
              ? SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: padding ?? const EdgeInsets.all(0),
                  child: child,
                )
              : Padding(
                  padding: padding ?? const EdgeInsets.all(0),
                  child: child,
                ),
        ),
      ],
    );
  }
}

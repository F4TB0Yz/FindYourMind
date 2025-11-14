import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/shared/domain/entities/screen_type.dart';
import 'package:find_your_mind/shared/presentation/widgets/custom_border_container.dart';
import 'package:flutter/material.dart';

class ContainerBorderScreens extends StatelessWidget {
  final ScreenType screenType;
  final Widget child;
  final Widget? endWidget;
  final double rightSpacing = 10;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ContainerBorderScreens({
    super.key,
    required this.screenType,
    required this.child,
    this.endWidget,
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
          // Header Habitos Titulo
          Container(
            width: double.infinity,
            height: 35,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              color: AppColors.darkBackground
            ),
            child: Stack(
              children: [
                // Texto centrado
                Center(
                  child: Text(
                    screenType.name,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Widget al final (si existe)
                if (endWidget != null)
                  Positioned(
                    right: rightSpacing,
                    top: 0,
                    bottom: 0,
                    child: Center(child: endWidget!),
                  ),
              ],
            ),
          ),
        
          Expanded(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(0),
              child: child,
            )
          )
        ],
      ),
    );
  }
}
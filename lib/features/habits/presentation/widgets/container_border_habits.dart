import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/core/constants/string_constants.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:find_your_mind/shared/presentation/widgets/custom_border_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ContainerBorderHabits extends StatelessWidget {
  final Widget child;
  final Widget? endWidget;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ContainerBorderHabits({
    super.key, 
    required this.child,
    this.endWidget,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final HabitsProvider habitsProvider = Provider.of<HabitsProvider>(context);

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
                    habitsProvider.titleScreen,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      letterSpacing: habitsProvider.titleScreen == AppStrings.habitsTitle ? 2 : 0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                
                // Widget al final (si existe)
                if (endWidget != null)
                  Positioned(
                    right: 0,
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
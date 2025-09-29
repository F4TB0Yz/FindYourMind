import 'package:find_your_mind/shared/presentation/widgets/custom_border_container.dart';
import 'package:flutter/material.dart';

class ContainerBorderHabits extends StatelessWidget {
  final Widget child;
  final CrossAxisAlignment crossAxisAlignment;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const ContainerBorderHabits({
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
      padding: padding,
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
              color: Color(0xFF2A2A2A)
            ),
            child: const Center(
              child: Text(
                'HABITOS',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w700,
                ),
              )
            ),
          ),
        
          const SizedBox(height: 10),

          Expanded(child: child)
        ],
      ),
    );
  }
}
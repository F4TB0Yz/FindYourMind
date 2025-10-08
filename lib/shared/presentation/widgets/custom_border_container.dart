import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:find_your_mind/features/notes/presentation/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CustomBorderContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const CustomBorderContainer({
    super.key,
    required this.child,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: themeProvider.themeMode == ThemeMode.light
            ? AppColors.darkBackground
            : const Color.fromARGB(255, 89, 85, 85),
          width: 0.4,
        )
      ),
      child: child,
    );
  }
}
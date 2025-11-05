import 'package:flutter/material.dart';

class CustomAuthButton extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final VoidCallback? onTap;

  const CustomAuthButton({
    super.key, 
    required this.child,
    this.width = 100,
    this.height = 50,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: child,
        ),
      ),
    );
  }
}
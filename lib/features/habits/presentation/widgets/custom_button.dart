import 'package:find_your_mind/core/constants/animation_constants.dart';
import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;

  const CustomButton({
    super.key, 
    required this.title, 
    this.onTap
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  Color backgroundColor = AppColors.darkBackground;
  bool _isPressed = false;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() {
        //backgroundColor = const Color.fromARGB(176, 71, 123, 77);
      }),
      onExit: (event) => setState(() {
        backgroundColor = AppColors.darkBackground;
      }),
      child: GestureDetector(
        onTap: () async {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        onTapDown: (_) {
          _scaleController.forward();
          setState(() {
            _isPressed = true;
          });
        },
        onTapUp: (_) {
          _scaleController.reverse();
          setState(() {
            _isPressed = false;
          });
        },
        onTapCancel: () {
          _scaleController.reverse();
          setState(() {
            _isPressed = false;
          });
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AnimatedContainer(
            duration: AnimationConstants.fastAnimation,
            width: double.infinity,
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: backgroundColor,
              boxShadow: _isPressed
                  ? [
                      const BoxShadow(
                        color: Color.fromRGBO(255, 255, 255, 0.4),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ]
                  : [
                      const BoxShadow(
                        color: Color.fromRGBO(255, 255, 255, 0.15),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500
                ),
              )
            ),
          ),
        ),
      ),
    );
  }
}
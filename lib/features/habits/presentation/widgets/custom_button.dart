import 'package:find_your_mind/core/constants/animation_constants.dart';
import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

/// Botón primario de la feature de hábitos.
///
/// Soporta escala en press y tiene un borde sutil permanente.
/// La sombra es oscura y discreta, sin efectos blancos dramáticos.
class CustomButton extends StatefulWidget {
  final String title;
  final VoidCallback? onTap;

  const CustomButton({
    super.key,
    required this.title,
    this.onTap,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) => _scaleController.reverse(),
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: AnimationConstants.fastAnimation,
          width: double.infinity,
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            color: AppColors.darkBackground,
            border: Border.all(
              color: AppColors.borderSubtle,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
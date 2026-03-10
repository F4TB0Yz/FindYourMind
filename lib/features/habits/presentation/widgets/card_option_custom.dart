import 'package:find_your_mind/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

/// Opción seleccionable usada en el selector de tipo de hábito.
///
/// Muestra un estado seleccionado claro mediante borde de color y fondo sutil,
/// y un estado deshabilitado cuando otro tipo ya fue elegido.
class CardOptionCustom extends StatelessWidget {
  final String title;
  final bool? canBeSelected;
  final VoidCallback? onTap;
  final bool isSelected;

  const CardOptionCustom({
    super.key,
    required this.title,
    this.onTap,
    this.canBeSelected,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = canBeSelected == false && !isSelected;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: isSelected
              ? AppColors.successMuted.withValues(alpha: 0.1)
              : AppColors.darkBackgroundAlt,
          border: Border.all(
            color: isSelected
                ? AppColors.successMuted.withValues(alpha: 0.6)
                : AppColors.borderSubtle,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected
                  ? AppColors.successMuted
                  : disabled
                      ? AppColors.textMuted
                      : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
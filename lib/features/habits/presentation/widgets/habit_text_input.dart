import 'package:flutter/material.dart';

/// Campo de texto reutilizable para los formularios de la feature de hábitos.
///
/// Encapsula el estilo y comportamiento estándar de los inputs de la feature,
/// evitando duplicar la configuración de [TextField] en múltiples pantallas.
class HabitTextInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final double fontSize;
  final bool isSubtitle;
  final int? maxLength;

  const HabitTextInput({
    super.key,
    required this.controller,
    required this.hintText,
    this.fontSize = 16,
    this.isSubtitle = false,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLength: maxLength,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: Colors.white60,
        ),
        counterText: '',
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 10),
      ),
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: isSubtitle ? Colors.white60 : Colors.white,
      ),
      cursorColor: Colors.white70,
    );
  }
}

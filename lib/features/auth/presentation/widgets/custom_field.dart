import 'package:flutter/material.dart';

class CustomAuthField extends StatelessWidget {
  final TextEditingController controller;
  final bool? isPassword;

  const CustomAuthField({super.key, required this.controller, this.isPassword});

  @override
  Widget build(BuildContext context) {
    const TextStyle hintStyle = TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w400
    );

    InputDecoration decoration = InputDecoration(
      filled: true,
      fillColor: const Color(0XFF2A2A2A),
      border: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(5)),
        borderSide: BorderSide.none,
      ),
      hintText: isPassword ?? false ? 'Contraseña' : 'Correo',
      hintStyle: const TextStyle(
        color: Colors.white54,
      ),
    );

    return SizedBox(
      height: 40,
      width: double.infinity,
      child: TextField(
        controller: controller,
        style: hintStyle,
        decoration: decoration,
        obscureText: isPassword ?? false,
      ),
    );
  }
}
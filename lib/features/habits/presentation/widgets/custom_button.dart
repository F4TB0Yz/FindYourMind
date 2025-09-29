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

class _CustomButtonState extends State<CustomButton> {
  Color backgroundColor = const Color(0xFF2A2A2A);
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (event) => setState(() {
        //backgroundColor = const Color.fromARGB(176, 71, 123, 77);
      }),
      onExit: (event) => setState(() {
        backgroundColor = const Color(0xFF2A2A2A);
      }),
      child: GestureDetector(
        onTap: () async {
          if (widget.onTap != null) {
            widget.onTap!();
          }
        },
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
        },
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
          });
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
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
    );
  }
}
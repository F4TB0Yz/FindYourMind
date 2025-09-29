import 'package:flutter/material.dart';

class CardOptionCustom extends StatefulWidget {
  final String title;
  final bool? canBeSelected;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  
  const CardOptionCustom({
    super.key,
    required this.title,
    this.onTap,
    this.canBeSelected,
    this.width,
    this.height,
  });

  @override
  State<CardOptionCustom> createState() => _CardOptionCustomState();
}

class _CardOptionCustomState extends State<CardOptionCustom> {
  Color colorCard = const Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) {
          widget.onTap!();
        }

        setState(() {
          colorCard = (widget.canBeSelected == true)
            ? const Color(0xFF3A3A3A) 
            : const Color(0xFF1A1A1A);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: colorCard
        ),
        child: Center(
          child: Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500
            ),
          ),
        ),
      ),
    );
  }
}
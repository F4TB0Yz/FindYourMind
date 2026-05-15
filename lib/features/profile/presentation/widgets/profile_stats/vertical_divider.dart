import 'package:flutter/material.dart';

class StatVerticalDivider extends StatelessWidget {
  const StatVerticalDivider({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
      width: 1,
      thickness: 1,
      indent: 16,
      endIndent: 16,
      color: color,
    );
  }
}

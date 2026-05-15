import 'package:flutter/material.dart';

class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: cs.outlineVariant, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text('o', style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
        ),
        Expanded(child: Divider(color: cs.outlineVariant, thickness: 1)),
      ],
    );
  }
}

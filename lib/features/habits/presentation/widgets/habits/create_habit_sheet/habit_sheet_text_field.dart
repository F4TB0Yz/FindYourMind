import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HabitSheetTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueKey<String>? fieldKey;
  final String? errorText;

  const HabitSheetTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.fieldKey,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          key: fieldKey,
          controller: controller,
          maxLines: 1,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurfaceVariant,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 11,
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: errorText != null
                    ? colorScheme.error
                    : colorScheme.outline.withValues(alpha: 0.5),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: errorText != null
                    ? colorScheme.error
                    : colorScheme.primary,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              errorText!,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}

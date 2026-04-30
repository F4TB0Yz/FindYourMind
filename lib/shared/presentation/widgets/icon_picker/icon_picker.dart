import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

class IconPicker {
  static Future<String?> showEmojiPicker({
    required BuildContext context,
    String? initialEmoji,
  }) async {
    final TextEditingController controller = TextEditingController(
      text: initialEmoji ?? '',
    );

    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (BuildContext context) {
        final cs = Theme.of(context).colorScheme;
        return Dialog(
          backgroundColor: cs.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: cs.outlineVariant, width: 1),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Selecciona un emoji',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        behavior: HitTestBehavior.opaque,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerLowest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: cs.outlineVariant, width: 1),
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCancel01,
                            size: 16,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 32),
                    decoration: InputDecoration(
                      hintText: 'Ej: 🧠',
                      hintStyle: TextStyle(color: cs.outline),
                      filled: true,
                      fillColor: cs.surfaceContainerLowest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: cs.outlineVariant, width: 1),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: cs.outlineVariant, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: cs.primary, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Cancelar',
                          style: TextStyle(color: cs.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final value = controller.text.trim();
                          Navigator.of(context).pop(value.isEmpty ? null : value);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Guardar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
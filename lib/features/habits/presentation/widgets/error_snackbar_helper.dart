import 'package:flutter/material.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:hugeicons/hugeicons.dart';

/// Helper para mostrar SnackBars de error automáticamente
class ErrorSnackBarHelper {
  static void showErrorIfNeeded(BuildContext context, HabitsProvider provider) {
    if (provider.hasError && provider.lastError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedAlert01,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      provider.lastError!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade700,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'Cerrar',
                textColor: Colors.white,
                onPressed: () => provider.clearError(),
              ),
            ),
          );
          
          // Limpiar error después de mostrarlo
          Future.delayed(const Duration(seconds: 4), () {
            if (context.mounted) {
              provider.clearError();
            }
          });
        }
      });
    }
  }

  /// Muestra un error de éxito (para operaciones exitosas)
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedCheckmarkCircle01,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Muestra un error de advertencia
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const HugeIcon(
              icon: HugeIcons.strokeRoundedAlertDiamond,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

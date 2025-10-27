import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';

/// Widget que muestra un banner de error cuando hay errores en HabitsProvider
class ErrorBannerWidget extends StatelessWidget {
  const ErrorBannerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitsProvider>(
      builder: (context, provider, child) {
        if (!provider.hasError) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade300),
          ),
          child: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.lastError ?? 'Error desconocido',
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 13,
                      ),
                    ),
                    if (provider.lastErrorTime != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _formatErrorTime(provider.lastErrorTime!),
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                color: Colors.red.shade700,
                iconSize: 20,
                onPressed: () => provider.clearError(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatErrorTime(DateTime errorTime) {
    final now = DateTime.now();
    final difference = now.difference(errorTime);

    if (difference.inSeconds < 60) {
      return 'Hace ${difference.inSeconds} segundos';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} minutos';
    } else {
      return 'Hace ${difference.inHours} horas';
    }
  }
}

import 'package:flutter/material.dart';

/// Banner informativo que se muestra cuando hay cambios sin sincronizar
/// 
/// Se puede usar en la parte superior de las pantallas para informar
/// al usuario que tiene cambios locales pendientes de sincronización
class OfflineModeBanner extends StatelessWidget {
  final int pendingChanges;
  final VoidCallback? onSyncPressed;

  const OfflineModeBanner({
    super.key,
    required this.pendingChanges,
    this.onSyncPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingChanges == 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade600,
            Colors.orange.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Modo offline activo',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$pendingChanges cambio${pendingChanges > 1 ? 's' : ''} pendiente${pendingChanges > 1 ? 's' : ''} de sincronización',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (onSyncPressed != null)
            TextButton.icon(
              onPressed: onSyncPressed,
              icon: Icon(Icons.sync, color: Colors.white, size: 18),
              label: Text(
                'Sincronizar',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
        ],
      ),
    );
  }
}

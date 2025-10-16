import 'package:find_your_mind/features/habits/presentation/providers/habits_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Widget que muestra el estado de sincronización y permite sincronizar manualmente
/// 
/// Características:
/// - Muestra badge con número de cambios pendientes
/// - Botón para sincronizar manualmente
/// - Feedback visual del estado de sincronización
/// - Mensajes de éxito/error con SnackBar
class SyncStatusIndicator extends StatefulWidget {
  const SyncStatusIndicator({super.key});

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator> {
  bool _isSyncing = false;

  Future<void> _handleSync(BuildContext context) async {
    if (_isSyncing) return;

    setState(() => _isSyncing = true);

    try {
      final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);
      final success = await habitsProvider.syncWithServer();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('✅ Sincronizado correctamente'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('No hay cambios pendientes o sin conexión'),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Error al sincronizar: $e')),
            ],
          ),
          backgroundColor: Colors.red.shade700,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final habitsProvider = Provider.of<HabitsProvider>(context, listen: false);

    return FutureBuilder<int>(
      future: habitsProvider.getPendingChangesCount(),
      builder: (context, snapshot) {
        final pendingCount = snapshot.data ?? 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Botón de sincronización
            IconButton(
              icon: _isSyncing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).iconTheme.color ?? Colors.white,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.cloud_sync,
                      color: pendingCount > 0 
                        ? Colors.orange 
                        : Theme.of(context).iconTheme.color,
                    ),
              tooltip: pendingCount > 0
                  ? 'Sincronizar $pendingCount cambio${pendingCount > 1 ? 's' : ''}'
                  : 'Sincronizar con el servidor',
              onPressed: _isSyncing ? null : () => _handleSync(context),
            ),
            
            // Badge con número de cambios pendientes
            if (pendingCount > 0 && !_isSyncing)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade700,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  constraints: BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    pendingCount > 99 ? '99+' : '$pendingCount',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

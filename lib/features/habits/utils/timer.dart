import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/widgets.dart';

/// Gestiona la actualización periódica del tiempo transcurrido de un hábito
/// 
/// Ajusta automáticamente el intervalo de actualización según la antigüedad:
/// - < 1 hora: actualiza cada segundo
/// - 1-24 horas: actualiza cada minuto
/// - 1-7 días: actualiza cada hora
/// - > 7 días: no requiere actualización automática
class HabitTimerManager {
  Timer? _timer;
  final VoidCallback onUpdate;
  final DateTime startDate;
  bool _isDisposed = false;

  HabitTimerManager({
    required this.startDate,
    required this.onUpdate,
  });

  /// Inicia el timer con el intervalo apropiado
  void start() {
    if (_isDisposed) return;
    
    final Duration updateInterval = _calculateUpdateInterval();
    
    if (updateInterval == Duration.zero) {
      // No se necesita actualización periódica
      developer.log('No se requiere timer para este hábito (muy antiguo)');
      onUpdate(); // Actualizar una vez
      return;
    }

    developer.log('Iniciando timer con intervalo: ${updateInterval.toString()}');
    
    // Primera actualización inmediata
    onUpdate();
    
    // Configurar actualizaciones periódicas
    _timer = Timer.periodic(updateInterval, (_) {
      if (!_isDisposed) {
        onUpdate();
      } else {
        _timer?.cancel();
      }
    });
  }

  /// Calcula el intervalo de actualización basado en la antigüedad del hábito
  Duration _calculateUpdateInterval() {
    final now = DateTime.now();
    final difference = now.difference(startDate);
    
    if (difference.inHours < 1) {
      // Menos de 1 hora: actualizar cada segundo
      return const Duration(seconds: 1);
    } else if (difference.inHours < 24) {
      // Entre 1 y 24 horas: actualizar cada minuto
      return const Duration(minutes: 1);
    } else if (difference.inDays < 7) {
      // Entre 1 y 7 días: actualizar cada hora
      return const Duration(hours: 1);
    } else {
      // Más de 7 días: no se necesita actualización frecuente
      return Duration.zero;
    }
  }

  /// Detiene y libera el timer
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _timer = null;
  }

  /// Verifica si el timer está activo
  bool get isActive => _timer?.isActive ?? false;
}
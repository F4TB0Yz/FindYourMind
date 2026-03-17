import 'package:flutter_test/flutter_test.dart';
import 'package:find_your_mind/features/habits/data/models/item_habit_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/type_habit.dart';

/// Pruebas para [ItemHabitModel]
///
/// Verifica que la serialización (deserialización en este caso) y la
/// conversión a entidades de dominio funcionen correctamente.
void main() {
  group('ItemHabitModel', () {
    // --- ARRANGE (Preparación) ---
    // JSON que simula la respuesta de la base de datos (Supabase/SQLite)
    final tJson = {
      'id': '1',
      'user_id': 'user123',
      'title': 'Tomar Agua',
      'description': 'Mantenerse hidratado',
      'initial_date': '2025-01-01T00:00:00.000',
      'type': 'health',
      'icon': 'water_drop',
      'daily_goal': 8,
      'progress': [],
    };

    // Modelo que esperamos obtener del JSON
    final tModel = ItemHabitModel(
      id: '1',
      userId: 'user123',
      title: 'Tomar Agua',
      description: 'Mantenerse hidratado',
      createdAt: DateTime.parse('2025-01-01T00:00:00.000'),
      typeHabit: 'health',
      iconString: 'water_drop',
      dailyGoal: 8,
      progress: [],
    );

    test('should return a valid model from JSON', () {
      // --- ACT (Ejecución) ---
      // Convertir el JSON a modelo
      final result = ItemHabitModel.fromJson(tJson);

      // --- ASSERT (Verificación) ---
      // Verificar que cada campo coincida con lo esperado
      expect(result.id, tModel.id);
      expect(result.userId, tModel.userId);
      expect(result.title, tModel.title);
      expect(result.description, tModel.description);
      expect(result.createdAt, tModel.createdAt);
      expect(result.typeHabit, tModel.typeHabit);
      expect(result.iconString, tModel.iconString);
      expect(result.dailyGoal, tModel.dailyGoal);
      expect(result.progress, tModel.progress);
    });

    test('should return a valid Entity when toEntity is called', () {
      // --- ACT (Ejecución) ---
      // Convertir el modelo a la entidad de dominio
      final result = tModel.toEntity();

      // --- ASSERT (Verificación) ---
      // Verificar que el resultado sea de tipo HabitEntity
      expect(result, isA<HabitEntity>());
      // Verificar mapeos de campos clave
      expect(result.id, tModel.id);
      expect(result.title, tModel.title);
      expect(result.type, TypeHabit.health);
    });
  });
}

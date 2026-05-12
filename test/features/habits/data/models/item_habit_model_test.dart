import 'package:find_your_mind/features/habits/data/models/item_habit_model.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../test_utils/test_output_style.dart';

void main() {
  group(label('ItemHabitModel'), () {
    final tJson = {
      'id': '1',
      'user_id': 'user123',
      'title': 'Tomar agua',
      'description': 'Mantenerse hidratado',
      'created_at': '2025-01-01T00:00:00.000',
      'initial_date': '2025-01-01T00:00:00.000',
      'category': 'health',
      'tracking_type': 'counter',
      'icon': '💧',
      'target_value': 8,
      'logs': [
        {
          'id': 'l1',
          'habit_id': '1',
          'date': '2025-01-01',
          'value': 3,
        },
      ],
    };

    final tModel = ItemHabitModel.fromJson(tJson);

    test(label('fromJson construye modelo válido'), () {
      expect(tModel.id, '1');
      expect(tModel.userId, 'user123');
      expect(tModel.category, 'health');
      expect(tModel.trackingType, 'counter');
      expect(tModel.targetValue, 8);
      expect(
        tModel.logs,
        const [
          HabitLog(id: 'l1', habitId: '1', date: '2025-01-01', value: 3),
        ],
      );
    });

    test(label('toEntity mapea a nueva forma de dominio'), () {
      final result = tModel.toEntity();

      expect(result, isA<HabitEntity>());
      expect(result.category, HabitCategory.health);
      expect(result.trackingType, HabitTrackingType.counter);
      expect(result.targetValue, 8);
      expect(result.todayValue, 0);
      expect(result.logs.length, 1);
    });
  });
}

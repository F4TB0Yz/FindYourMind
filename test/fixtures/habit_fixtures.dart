import 'package:find_your_mind/features/habits/domain/entities/habit_entity.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_category.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';
import 'package:find_your_mind/features/habits/domain/entities/habit_log.dart';

const tUserId = 'test-user-123';
const tHabitId = 'habit-456';
const tLogId = 'log-789';

const tHabitJson = {
  'id': tHabitId,
  'user_id': tUserId,
  'title': 'Morning Run',
  'description': 'Run 5km every morning',
  'icon': '🏃',
  'category': 'health',
  'tracking_type': 'single',
  'target_value': 1,
  'initial_date': '2025-01-15',
  'created_at': '2025-01-15T08:00:00Z',
  'updated_at': '2025-01-15T08:00:00Z',
};

const tLogJson = {
  'id': tLogId,
  'habit_id': tHabitId,
  'date': '2025-01-20',
  'value': 1,
};

const tHabitEntity = HabitEntity(
  id: tHabitId,
  userId: tUserId,
  title: 'Morning Run',
  description: 'Run 5km every morning',
  icon: '🏃',
  category: HabitCategory.health,
  trackingType: HabitTrackingType.single,
  targetValue: 1,
  initialDate: '2025-01-15',
  logs: [],
);

final tHabitWithLog = tHabitEntity.copyWith(
  logs: [
    const HabitLog(
      id: tLogId,
      habitId: tHabitId,
      date: '2025-01-20',
      value: 1,
    ),
  ],
);

const tCounterHabit = HabitEntity(
  id: 'counter-habit',
  userId: tUserId,
  title: 'Drink Water',
  description: 'Drink 8 glasses of water',
  icon: '💧',
  category: HabitCategory.health,
  trackingType: HabitTrackingType.counter,
  targetValue: 8,
  initialDate: '2025-01-10',
  logs: [],
);

const tTimedHabit = HabitEntity(
  id: 'timed-habit',
  userId: tUserId,
  title: 'Meditate',
  description: 'Meditate for 10 minutes',
  icon: '🧘',
  category: HabitCategory.personal,
  trackingType: HabitTrackingType.timed,
  targetValue: 600,
  initialDate: '2025-01-05',
  logs: [],
);

const tHabitLog = HabitLog(
  id: tLogId,
  habitId: tHabitId,
  date: '2025-01-20',
  value: 1,
);

const tPendingSyncItem = {
  'id': 'sync-1',
  'table_name': 'habits',
  'record_id': tHabitId,
  'operation': 'create',
  'payload': tHabitJson,
  'retry_count': 0,
  'created_at': '2025-01-20T10:00:00Z',
};
import 'package:find_your_mind/features/habits/domain/entities/habit_tracking_type.dart';

class HabitTrackingTypeModel {
  static HabitTrackingType fromString(String trackingType) {
    switch (trackingType) {
      case 'single':
        return HabitTrackingType.single;
      case 'timed':
        return HabitTrackingType.timed;
      case 'counter':
        return HabitTrackingType.counter;
      default:
        return HabitTrackingType.single;
    }
  }

  static String toStringValue(HabitTrackingType trackingType) {
    switch (trackingType) {
      case HabitTrackingType.single:
        return 'single';
      case HabitTrackingType.timed:
        return 'timed';
      case HabitTrackingType.counter:
        return 'counter';
    }
  }
}

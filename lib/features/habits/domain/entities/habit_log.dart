import 'package:equatable/equatable.dart';

class HabitLog extends Equatable {
  final String id;
  final String habitId;
  final String date;
  final int value;

  const HabitLog({
    required this.id,
    required this.habitId,
    required this.date,
    required this.value,
  });

  HabitLog copyWith({
    String? id,
    String? habitId,
    String? date,
    int? value,
  }) {
    return HabitLog(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      value: value ?? this.value,
    );
  }

  @override
  List<Object?> get props => [id, habitId, date, value];
}

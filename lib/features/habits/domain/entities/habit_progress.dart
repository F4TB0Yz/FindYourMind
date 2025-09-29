class HabitProgress {
  final String id;
  final String habitId;
  final String date;
  final int dailyGoal;
  final int dailyCounter;

  const HabitProgress({
    required this.id,
    required this.habitId,
    required this.date,
    required this.dailyGoal,
    required this.dailyCounter
  });

  HabitProgress copyWith({
    String? id,
    String? habitId,
    String? date,
    int? dailyGoal,
    int? dailyCounter
  }) {
    return HabitProgress(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      dailyCounter: dailyCounter ?? this.dailyCounter
    );
  }
}
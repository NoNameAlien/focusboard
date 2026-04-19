class HabitCompletion {
  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.date,
    required this.isCompleted,
  });

  final String id;
  final String habitId;
  final DateTime date;
  final bool isCompleted;
}

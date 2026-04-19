class MoodEntry {
  const MoodEntry({
    required this.id,
    required this.date,
    required this.moodValue,
    this.comment,
  });

  final String id;
  final DateTime date;
  final int moodValue;
  final String? comment;
}

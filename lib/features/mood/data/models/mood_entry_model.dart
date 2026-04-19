import '../../domain/entities/mood_entry.dart';

class MoodEntryModel {
  const MoodEntryModel({
    required this.id,
    required this.date,
    required this.moodValue,
    this.comment,
  });

  final String id;
  final DateTime date;
  final int moodValue;
  final String? comment;

  MoodEntry toEntity() {
    return MoodEntry(
      id: id,
      date: date,
      moodValue: moodValue,
      comment: comment,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moodValue': moodValue,
      'comment': comment,
    };
  }

  factory MoodEntryModel.fromJson(Map<String, dynamic> json) {
    return MoodEntryModel(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      moodValue: json['moodValue'] as int,
      comment: json['comment'] as String?,
    );
  }
}

import '../../domain/entities/habit_completion.dart';

class HabitCompletionModel {
  const HabitCompletionModel({
    required this.id,
    required this.habitId,
    required this.date,
    required this.isCompleted,
  });

  final String id;
  final String habitId;
  final DateTime date;
  final bool isCompleted;

  HabitCompletion toEntity() {
    return HabitCompletion(
      id: id,
      habitId: habitId,
      date: date,
      isCompleted: isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habitId': habitId,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  factory HabitCompletionModel.fromJson(Map<String, dynamic> json) {
    return HabitCompletionModel(
      id: json['id'] as String,
      habitId: json['habitId'] as String,
      date: DateTime.parse(json['date'] as String),
      isCompleted: json['isCompleted'] as bool,
    );
  }

  factory HabitCompletionModel.fromEntity(HabitCompletion completion) {
    return HabitCompletionModel(
      id: completion.id,
      habitId: completion.habitId,
      date: completion.date,
      isCompleted: completion.isCompleted,
    );
  }
}

import '../../domain/entities/habit.dart';

class HabitDto {
  const HabitDto({
    required this.id,
    required this.title,
    this.description,
    this.color,
    this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String? description;
  final int? color;
  final int? icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  Habit toEntity() {
    return Habit(
      id: id,
      title: title,
      description: description,
      color: color,
      icon: icon,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'color': color,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory HabitDto.fromJson(Map<String, dynamic> json) {
    return HabitDto(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      color: json['color'] as int?,
      icon: json['icon'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

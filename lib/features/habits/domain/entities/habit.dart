class Habit {
  const Habit({
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
}

import '../../domain/entities/habit.dart';
import '../dto/habit_dto.dart';

extension HabitDtoMapper on HabitDto {
  Habit toHabit() => toEntity();
}

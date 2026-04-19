import '../../../../core/utils/result.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class UpdateHabit {
  const UpdateHabit(this._repository);

  final HabitRepository _repository;

  Future<Result<Habit>> call({
    required String id,
    required String title,
    String? description,
    int? color,
    int? icon,
  }) {
    return _repository.updateHabit(
      id: id,
      title: title,
      description: description,
      color: color,
      icon: icon,
    );
  }
}

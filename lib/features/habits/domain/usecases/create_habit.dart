import '../../../../core/utils/result.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class CreateHabit {
  const CreateHabit(this._repository);

  final HabitRepository _repository;

  Future<Result<Habit>> call({
    required String title,
    String? description,
    int? color,
    int? icon,
  }) {
    return _repository.createHabit(
      title: title,
      description: description,
      color: color,
      icon: icon,
    );
  }
}

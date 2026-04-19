import '../../../../core/utils/result.dart';
import '../entities/habit.dart';
import '../repositories/habit_repository.dart';

class GetHabitById {
  const GetHabitById(this._repository);

  final HabitRepository _repository;

  Future<Result<Habit>> call(String id) => _repository.getHabitById(id);
}

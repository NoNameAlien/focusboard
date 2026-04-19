import '../../../../core/utils/result.dart';
import '../repositories/habit_completion_repository.dart';

class UnmarkHabitCompleted {
  const UnmarkHabitCompleted(this._repository);

  final HabitCompletionRepository _repository;

  Future<Result<void>> call(String habitId) {
    return _repository.unmarkHabitCompleted(habitId);
  }
}

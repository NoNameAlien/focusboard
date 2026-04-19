import '../../../../core/utils/result.dart';
import '../entities/habit_completion.dart';
import '../repositories/habit_completion_repository.dart';

class MarkHabitCompleted {
  const MarkHabitCompleted(this._repository);

  final HabitCompletionRepository _repository;

  Future<Result<HabitCompletion>> call(String habitId) {
    return _repository.markHabitCompleted(habitId);
  }
}

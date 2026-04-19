import '../../../../core/utils/result.dart';
import '../entities/habit_completion.dart';
import '../repositories/habit_completion_repository.dart';

class GetTodayCompletions {
  const GetTodayCompletions(this._repository);

  final HabitCompletionRepository _repository;

  Future<Result<List<HabitCompletion>>> call() =>
      _repository.getTodayCompletions();
}

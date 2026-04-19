import '../../../../core/utils/result.dart';
import '../entities/habit_completion.dart';

abstract class HabitCompletionRepository {
  Future<Result<List<HabitCompletion>>> getTodayCompletions();
  Future<Result<HabitCompletion>> markHabitCompleted(String habitId);
  Future<Result<void>> unmarkHabitCompleted(String habitId);
}

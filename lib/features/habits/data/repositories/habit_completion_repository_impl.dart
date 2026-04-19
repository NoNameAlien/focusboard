import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/habit_completion.dart';
import '../../domain/repositories/habit_completion_repository.dart';
import '../datasources/habit_completion_local_data_source.dart';

class HabitCompletionRepositoryImpl implements HabitCompletionRepository {
  const HabitCompletionRepositoryImpl(this._localDataSource);

  final HabitCompletionLocalDataSource _localDataSource;

  @override
  Future<Result<List<HabitCompletion>>> getTodayCompletions() async {
    try {
      final completions = await _localDataSource.getTodayCompletions();
      return Result.ok<List<HabitCompletion>>(
        completions.map((item) => item.toEntity()).toList(growable: false),
      );
    } on Failure catch (failure) {
      return Result.err<List<HabitCompletion>>(failure);
    } catch (_) {
      return Result.err<List<HabitCompletion>>(
        const Failure('Failed to load today completions.'),
      );
    }
  }

  @override
  Future<Result<HabitCompletion>> markHabitCompleted(String habitId) async {
    try {
      final completion = await _localDataSource.markHabitCompleted(habitId);
      return Result.ok<HabitCompletion>(completion.toEntity());
    } on Failure catch (failure) {
      return Result.err<HabitCompletion>(failure);
    } catch (_) {
      return Result.err<HabitCompletion>(
        const Failure('Failed to mark habit as completed.'),
      );
    }
  }

  @override
  Future<Result<void>> unmarkHabitCompleted(String habitId) async {
    try {
      await _localDataSource.unmarkHabitCompleted(habitId);
      return Result.ok<void>();
    } on Failure catch (failure) {
      return Result.err<void>(failure);
    } catch (_) {
      return Result.err<void>(
        const Failure('Failed to unmark habit completion.'),
      );
    }
  }
}

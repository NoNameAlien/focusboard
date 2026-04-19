import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/habit.dart';
import '../../domain/repositories/habit_repository.dart';
import '../datasources/habit_completion_local_data_source.dart';
import '../datasources/habits_local_data_source.dart';
import '../mappers/habit_mapper.dart';

class HabitRepositoryImpl implements HabitRepository {
  const HabitRepositoryImpl(
    this._localDataSource,
    this._completionLocalDataSource,
  );

  final HabitsLocalDataSource _localDataSource;
  final HabitCompletionLocalDataSource _completionLocalDataSource;

  @override
  Future<Result<List<Habit>>> getHabits() async {
    try {
      final habits = await _localDataSource.getHabits();
      return Result.ok<List<Habit>>(
        habits.map((habit) => habit.toHabit()).toList(growable: false),
      );
    } on Failure catch (failure) {
      return Result.err<List<Habit>>(failure);
    } catch (_) {
      return Result.err<List<Habit>>(const Failure('Failed to load habits.'));
    }
  }

  @override
  Future<Result<Habit>> getHabitById(String id) async {
    try {
      final habit = await _localDataSource.getHabitById(id);
      return Result.ok<Habit>(habit.toHabit());
    } on Failure catch (failure) {
      return Result.err<Habit>(failure);
    } catch (_) {
      return Result.err<Habit>(const Failure('Failed to load habit details.'));
    }
  }

  @override
  Future<Result<Habit>> createHabit({
    required String title,
    String? description,
    int? color,
    int? icon,
  }) async {
    try {
      final habit = await _localDataSource.createHabit(
        title: title,
        description: description,
        color: color,
        icon: icon,
      );
      return Result.ok<Habit>(habit.toHabit());
    } on Failure catch (failure) {
      return Result.err<Habit>(failure);
    } catch (_) {
      return Result.err<Habit>(const Failure('Failed to create habit.'));
    }
  }

  @override
  Future<Result<Habit>> updateHabit({
    required String id,
    required String title,
    String? description,
    int? color,
    int? icon,
  }) async {
    try {
      final habit = await _localDataSource.updateHabit(
        id: id,
        title: title,
        description: description,
        color: color,
        icon: icon,
      );
      return Result.ok<Habit>(habit.toHabit());
    } on Failure catch (failure) {
      return Result.err<Habit>(failure);
    } catch (_) {
      return Result.err<Habit>(const Failure('Failed to update habit.'));
    }
  }

  @override
  Future<Result<void>> deleteHabit(String id) async {
    try {
      await _localDataSource.deleteHabit(id);
      await _completionLocalDataSource.deleteCompletionsForHabit(id);
      return Result.ok<void>();
    } on Failure catch (failure) {
      return Result.err<void>(failure);
    } catch (_) {
      return Result.err<void>(const Failure('Failed to delete habit.'));
    }
  }
}

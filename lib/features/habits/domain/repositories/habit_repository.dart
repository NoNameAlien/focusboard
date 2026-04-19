import '../../../../core/utils/result.dart';
import '../entities/habit.dart';

abstract class HabitRepository {
  Future<Result<List<Habit>>> getHabits();
  Future<Result<Habit>> getHabitById(String id);
  Future<Result<Habit>> createHabit({
    required String title,
    String? description,
    int? color,
    int? icon,
  });
  Future<Result<Habit>> updateHabit({
    required String id,
    required String title,
    String? description,
    int? color,
    int? icon,
  });
  Future<Result<void>> deleteHabit(String id);
}

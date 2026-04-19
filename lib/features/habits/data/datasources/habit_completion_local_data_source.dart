import '../../../../core/error/failures.dart';
import '../../../../core/storage/app_storage.dart';
import '../../../../core/storage/json_store.dart';
import '../models/habit_completion_model.dart';

abstract class HabitCompletionLocalDataSource {
  Future<void> initialize();
  Future<List<HabitCompletionModel>> getTodayCompletions();
  Future<HabitCompletionModel> markHabitCompleted(String habitId);
  Future<void> unmarkHabitCompleted(String habitId);
  Future<void> deleteCompletionsForHabit(String habitId);
}

class FileHabitCompletionLocalDataSource
    implements HabitCompletionLocalDataSource {
  FileHabitCompletionLocalDataSource(AppStorage storage)
    : _store = JsonListStore<HabitCompletionModel>(
        storage: storage,
        fileName: 'habit_completions.json',
        fromJson: HabitCompletionModel.fromJson,
        toJson: (value) => value.toJson(),
      );

  final JsonListStore<HabitCompletionModel> _store;

  @override
  Future<void> initialize() async {
    final existing = await _store.readAll();
    if (existing.isNotEmpty) {
      return;
    }

    final today = _today;
    await _store.writeAll([
      HabitCompletionModel(
        id: 'completion_habit_1_${today.toIso8601String()}',
        habitId: 'habit_1',
        date: today,
        isCompleted: true,
      ),
    ]);
  }

  @override
  Future<List<HabitCompletionModel>> getTodayCompletions() async {
    final today = _today;
    final completions = await _store.readAll();
    return completions
        .where((completion) => _isSameDay(completion.date, today))
        .toList(growable: false);
  }

  @override
  Future<HabitCompletionModel> markHabitCompleted(String habitId) async {
    final today = _today;
    final completions = await _store.readAll();
    final index = completions.indexWhere(
      (completion) =>
          completion.habitId == habitId && _isSameDay(completion.date, today),
    );

    final completion = HabitCompletionModel(
      id: index == -1
          ? 'completion_${habitId}_${today.microsecondsSinceEpoch}'
          : completions[index].id,
      habitId: habitId,
      date: today,
      isCompleted: true,
    );

    final nextCompletions = [...completions];
    if (index == -1) {
      nextCompletions.add(completion);
    } else {
      nextCompletions[index] = completion;
    }

    await _store.writeAll(nextCompletions);
    return completion;
  }

  @override
  Future<void> unmarkHabitCompleted(String habitId) async {
    final today = _today;
    final completions = await _store.readAll();
    final nextCompletions = completions
        .where(
          (completion) =>
              !(completion.habitId == habitId &&
                  _isSameDay(completion.date, today)),
        )
        .toList(growable: false);

    if (nextCompletions.length == completions.length) {
      throw const Failure('Completion for today was not found.');
    }

    await _store.writeAll(nextCompletions);
  }

  @override
  Future<void> deleteCompletionsForHabit(String habitId) async {
    final completions = await _store.readAll();
    final nextCompletions = completions
        .where((completion) => completion.habitId != habitId)
        .toList(growable: false);
    await _store.writeAll(nextCompletions);
  }

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}

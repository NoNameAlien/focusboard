import 'package:flutter/foundation.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_completion.dart';
import '../../domain/usecases/create_habit.dart';
import '../../domain/usecases/get_habits.dart';
import '../../domain/usecases/get_today_completions.dart';
import '../../domain/usecases/mark_habit_completed.dart';
import '../../domain/usecases/unmark_habit_completed.dart';
import 'habits_state.dart';

class HabitsController extends ChangeNotifier {
  HabitsController({
    required GetHabits getHabits,
    required CreateHabit createHabit,
    required GetTodayCompletions getTodayCompletions,
    required MarkHabitCompleted markHabitCompleted,
    required UnmarkHabitCompleted unmarkHabitCompleted,
  }) : _getHabits = getHabits,
       _createHabit = createHabit,
       _getTodayCompletions = getTodayCompletions,
       _markHabitCompleted = markHabitCompleted,
       _unmarkHabitCompleted = unmarkHabitCompleted;

  final GetHabits _getHabits;
  final CreateHabit _createHabit;
  final GetTodayCompletions _getTodayCompletions;
  final MarkHabitCompleted _markHabitCompleted;
  final UnmarkHabitCompleted _unmarkHabitCompleted;

  HabitsState _state = const HabitsInitialState();

  HabitsState get state => _state;

  Future<void> loadHabits() async {
    _emit(
      HabitsLoadingState(
        previousHabits: _state.habits,
        previousTodayCompletions: _state.todayCompletions,
        previousUpdatingHabitIds: _state.updatingHabitIds,
      ),
    );

    final habitsResult = await _getHabits();
    if (habitsResult.isFailure) {
      _emit(
        HabitsFailureState(
          message: habitsResult.failure?.message ?? 'Failed to load habits.',
          previousHabits: _state.habits,
          previousTodayCompletions: _state.todayCompletions,
          previousUpdatingHabitIds: _state.updatingHabitIds,
        ),
      );
      return;
    }

    final completionsResult = await _getTodayCompletions();
    if (completionsResult.isFailure) {
      _emit(
        HabitsFailureState(
          message:
              completionsResult.failure?.message ??
              'Failed to load today completions.',
          previousHabits: _state.habits,
          previousTodayCompletions: _state.todayCompletions,
          previousUpdatingHabitIds: _state.updatingHabitIds,
        ),
      );
      return;
    }

    final habits = habitsResult.data ?? const <Habit>[];
    final todayCompletions = _filterCompletionsForKnownHabits(
      completionsResult.data ?? const <HabitCompletion>[],
      habits,
    );

    _emit(
      _buildContentState(habits: habits, todayCompletions: todayCompletions),
    );
  }

  Future<Result<Habit>> createHabit({
    required String title,
    String? description,
  }) {
    return _createHabit(title: title, description: description);
  }

  Future<void> toggleHabitCompletion(String habitId) async {
    if (_state.isHabitUpdating(habitId)) {
      return;
    }

    final nextUpdatingIds = {..._state.updatingHabitIds, habitId};
    _emit(
      _buildContentState(
        habits: _state.habits,
        todayCompletions: _state.todayCompletions,
        updatingHabitIds: nextUpdatingIds,
      ),
    );

    final isCompleted = _state.isHabitCompletedToday(habitId);
    final result = isCompleted
        ? await _unmarkHabitCompleted(habitId)
        : await _markHabitCompleted(habitId);

    if (result.isFailure) {
      final clearedIds = {...nextUpdatingIds}..remove(habitId);
      _emit(
        _buildContentState(
          habits: _state.habits,
          todayCompletions: _state.todayCompletions,
          updatingHabitIds: clearedIds,
          message: result.failure?.message ?? 'Failed to update completion.',
        ),
      );
      return;
    }

    await _refreshTodayCompletions(
      updatingHabitIds: nextUpdatingIds,
      changedHabitId: habitId,
    );
  }

  Future<void> _refreshTodayCompletions({
    required Set<String> updatingHabitIds,
    required String changedHabitId,
  }) async {
    final completionsResult = await _getTodayCompletions();
    final clearedIds = {...updatingHabitIds}..remove(changedHabitId);

    if (completionsResult.isFailure) {
      _emit(
        _buildContentState(
          habits: _state.habits,
          todayCompletions: _state.todayCompletions,
          updatingHabitIds: clearedIds,
          message:
              completionsResult.failure?.message ??
              'Failed to refresh completions.',
        ),
      );
      return;
    }

    final completions = _filterCompletionsForKnownHabits(
      completionsResult.data ?? const <HabitCompletion>[],
      _state.habits,
    );

    _emit(
      _buildContentState(
        habits: _state.habits,
        todayCompletions: completions,
        updatingHabitIds: clearedIds,
      ),
    );
  }

  List<HabitCompletion> _filterCompletionsForKnownHabits(
    List<HabitCompletion> completions,
    List<Habit> habits,
  ) {
    final knownHabitIds = habits.map((habit) => habit.id).toSet();
    return completions
        .where((completion) => knownHabitIds.contains(completion.habitId))
        .toList(growable: false);
  }

  HabitsState _buildContentState({
    required List<Habit> habits,
    required List<HabitCompletion> todayCompletions,
    Set<String> updatingHabitIds = const {},
    String? message,
  }) {
    if (habits.isEmpty) {
      return HabitsEmptyState(
        todayCompletions: todayCompletions,
        updatingHabitIds: updatingHabitIds,
      );
    }

    return HabitsLoadedState(
      habits: habits,
      todayCompletions: todayCompletions,
      updatingHabitIds: updatingHabitIds,
      message: message,
    );
  }

  void _emit(HabitsState state) {
    _state = state;
    notifyListeners();
  }
}

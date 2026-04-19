import '../../domain/entities/habit.dart';
import '../../domain/entities/habit_completion.dart';

sealed class HabitsState {
  const HabitsState();

  List<Habit> get habits;
  List<HabitCompletion> get todayCompletions;
  Set<String> get updatingHabitIds;
  String? get message;

  bool get isLoading => this is HabitsLoadingState;
  int get totalHabits => habits.length;

  int get completedTodayCount =>
      todayCompletions.where((item) => item.isCompleted).length;

  double get completionRate {
    if (totalHabits == 0) {
      return 0;
    }
    return completedTodayCount / totalHabits;
  }

  bool isHabitCompletedToday(String habitId) {
    return todayCompletions.any(
      (completion) => completion.habitId == habitId && completion.isCompleted,
    );
  }

  bool isHabitUpdating(String habitId) => updatingHabitIds.contains(habitId);
}

final class HabitsInitialState extends HabitsState {
  const HabitsInitialState();

  @override
  List<Habit> get habits => const [];

  @override
  List<HabitCompletion> get todayCompletions => const [];

  @override
  Set<String> get updatingHabitIds => const {};

  @override
  String? get message => null;
}

final class HabitsLoadingState extends HabitsState {
  const HabitsLoadingState({
    this.previousHabits = const [],
    this.previousTodayCompletions = const [],
    this.previousUpdatingHabitIds = const {},
  });

  final List<Habit> previousHabits;
  final List<HabitCompletion> previousTodayCompletions;
  final Set<String> previousUpdatingHabitIds;

  @override
  List<Habit> get habits => previousHabits;

  @override
  List<HabitCompletion> get todayCompletions => previousTodayCompletions;

  @override
  Set<String> get updatingHabitIds => previousUpdatingHabitIds;

  @override
  String? get message => null;
}

final class HabitsEmptyState extends HabitsState {
  const HabitsEmptyState({
    this.todayCompletions = const [],
    this.updatingHabitIds = const {},
  });

  @override
  final List<HabitCompletion> todayCompletions;

  @override
  final Set<String> updatingHabitIds;

  @override
  List<Habit> get habits => const [];

  @override
  String? get message => null;
}

final class HabitsLoadedState extends HabitsState {
  const HabitsLoadedState({
    required this.habits,
    this.todayCompletions = const [],
    this.updatingHabitIds = const {},
    this.message,
  });

  @override
  final List<Habit> habits;

  @override
  final List<HabitCompletion> todayCompletions;

  @override
  final Set<String> updatingHabitIds;

  @override
  final String? message;
}

final class HabitsFailureState extends HabitsState {
  const HabitsFailureState({
    required this.message,
    this.previousHabits = const [],
    this.previousTodayCompletions = const [],
    this.previousUpdatingHabitIds = const {},
  });

  final List<Habit> previousHabits;
  final List<HabitCompletion> previousTodayCompletions;
  final Set<String> previousUpdatingHabitIds;

  @override
  final String message;

  @override
  List<Habit> get habits => previousHabits;

  @override
  List<HabitCompletion> get todayCompletions => previousTodayCompletions;

  @override
  Set<String> get updatingHabitIds => previousUpdatingHabitIds;
}

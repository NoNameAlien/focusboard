import '../../domain/entities/habit.dart';

enum HabitEditorStatus { initial, ready, submitting, success, failure }

class HabitEditorState {
  const HabitEditorState({required this.status, this.habit, this.message});

  const HabitEditorState.initial() : this(status: HabitEditorStatus.initial);

  final HabitEditorStatus status;
  final Habit? habit;
  final String? message;

  bool get isSubmitting => status == HabitEditorStatus.submitting;

  HabitEditorState copyWith({
    HabitEditorStatus? status,
    Habit? habit,
    String? message,
    bool clearHabit = false,
    bool clearMessage = false,
  }) {
    return HabitEditorState(
      status: status ?? this.status,
      habit: clearHabit ? null : habit ?? this.habit,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}

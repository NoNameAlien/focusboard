import '../../domain/entities/mood_entry.dart';

enum MoodStatus { initial, loading, loaded, saving, failure }

class MoodState {
  const MoodState({
    required this.status,
    this.todayEntry,
    this.history = const [],
    this.message,
  });

  const MoodState.initial() : this(status: MoodStatus.initial);

  final MoodStatus status;
  final MoodEntry? todayEntry;
  final List<MoodEntry> history;
  final String? message;

  bool get isLoading => status == MoodStatus.loading;
  bool get isSaving => status == MoodStatus.saving;
  bool get hasMoodToday => todayEntry != null;

  MoodState copyWith({
    MoodStatus? status,
    MoodEntry? todayEntry,
    List<MoodEntry>? history,
    String? message,
    bool clearTodayEntry = false,
    bool clearMessage = false,
  }) {
    return MoodState(
      status: status ?? this.status,
      todayEntry: clearTodayEntry ? null : (todayEntry ?? this.todayEntry),
      history: history ?? this.history,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}

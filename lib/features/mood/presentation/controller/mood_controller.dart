import 'package:flutter/foundation.dart';

import '../../domain/entities/mood_entry.dart';
import '../../domain/usecases/get_mood_history.dart';
import '../../domain/usecases/get_today_mood_entry.dart';
import '../../domain/usecases/save_mood_entry.dart';
import 'mood_state.dart';

class MoodController extends ChangeNotifier {
  MoodController({
    required GetTodayMoodEntry getTodayMoodEntry,
    required GetMoodHistory getMoodHistory,
    required SaveMoodEntry saveMoodEntry,
  }) : _getTodayMoodEntry = getTodayMoodEntry,
       _getMoodHistory = getMoodHistory,
       _saveMoodEntry = saveMoodEntry;

  final GetTodayMoodEntry _getTodayMoodEntry;
  final GetMoodHistory _getMoodHistory;
  final SaveMoodEntry _saveMoodEntry;

  MoodState _state = const MoodState.initial();

  MoodState get state => _state;

  Future<void> loadMoodData() async {
    _emit(_state.copyWith(status: MoodStatus.loading, clearMessage: true));

    final todayResult = await _getTodayMoodEntry();
    if (todayResult.isFailure) {
      _emit(
        _state.copyWith(
          status: MoodStatus.failure,
          message: todayResult.failure?.message ?? 'Failed to load today mood.',
        ),
      );
      return;
    }

    final historyResult = await _getMoodHistory();
    if (historyResult.isFailure) {
      _emit(
        _state.copyWith(
          status: MoodStatus.failure,
          message:
              historyResult.failure?.message ?? 'Failed to load mood history.',
        ),
      );
      return;
    }

    _emit(
      _state.copyWith(
        status: MoodStatus.loaded,
        todayEntry: todayResult.data,
        history: historyResult.data ?? const [],
        clearMessage: true,
      ),
    );
  }

  Future<MoodEntry?> saveMoodEntry({
    required int moodValue,
    String? comment,
  }) async {
    _emit(_state.copyWith(status: MoodStatus.saving, clearMessage: true));

    final result = await _saveMoodEntry(moodValue: moodValue, comment: comment);
    if (result.isFailure || result.data == null) {
      _emit(
        _state.copyWith(
          status: MoodStatus.failure,
          message: result.failure?.message ?? 'Failed to save mood entry.',
        ),
      );
      return null;
    }

    final entry = result.data!;
    final nextHistory = _upsertHistoryEntry(entry, _state.history);
    _emit(
      _state.copyWith(
        status: MoodStatus.loaded,
        todayEntry: entry,
        history: nextHistory,
        clearMessage: true,
      ),
    );
    return entry;
  }

  List<MoodEntry> _upsertHistoryEntry(
    MoodEntry entry,
    List<MoodEntry> history,
  ) {
    final nextHistory = [...history];
    final index = nextHistory.indexWhere((item) => item.id == entry.id);
    if (index == -1) {
      nextHistory.add(entry);
    } else {
      nextHistory[index] = entry;
    }
    nextHistory.sort((a, b) => b.date.compareTo(a.date));
    return nextHistory;
  }

  void _emit(MoodState state) {
    _state = state;
    notifyListeners();
  }
}

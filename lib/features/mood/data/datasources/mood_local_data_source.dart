import '../../../../core/error/failures.dart';
import '../../../../core/storage/app_storage.dart';
import '../../../../core/storage/json_store.dart';
import '../models/mood_entry_model.dart';

abstract class MoodLocalDataSource {
  Future<void> initialize();
  Future<MoodEntryModel?> getTodayMoodEntry();
  Future<List<MoodEntryModel>> getMoodHistory();
  Future<MoodEntryModel> saveMoodEntry({
    required int moodValue,
    String? comment,
  });
}

class FileMoodLocalDataSource implements MoodLocalDataSource {
  FileMoodLocalDataSource(AppStorage storage)
    : _store = JsonListStore<MoodEntryModel>(
        storage: storage,
        fileName: 'mood_entries.json',
        fromJson: MoodEntryModel.fromJson,
        toJson: (value) => value.toJson(),
      );

  final JsonListStore<MoodEntryModel> _store;

  @override
  Future<void> initialize() async {
    final existing = await _store.readAll();
    if (existing.isNotEmpty) {
      return;
    }
    await _store.writeAll(const []);
  }

  @override
  Future<MoodEntryModel?> getTodayMoodEntry() async {
    final entries = await _store.readAll();
    final today = _today;
    for (final entry in entries) {
      if (_isSameDay(entry.date, today)) {
        return entry;
      }
    }
    return null;
  }

  @override
  Future<List<MoodEntryModel>> getMoodHistory() async {
    final entries = await _store.readAll();
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  @override
  Future<MoodEntryModel> saveMoodEntry({
    required int moodValue,
    String? comment,
  }) async {
    if (moodValue < 1 || moodValue > 5) {
      throw const Failure('Mood value should be between 1 and 5.');
    }

    final entries = await _store.readAll();
    final today = _today;
    final normalizedComment = _normalizeComment(comment);
    final index = entries.indexWhere((entry) => _isSameDay(entry.date, today));

    final entry = MoodEntryModel(
      id: index == -1
          ? 'mood_${today.microsecondsSinceEpoch}'
          : entries[index].id,
      date: today,
      moodValue: moodValue,
      comment: normalizedComment,
    );

    final nextEntries = [...entries];
    if (index == -1) {
      nextEntries.add(entry);
    } else {
      nextEntries[index] = entry;
    }

    await _store.writeAll(nextEntries);
    return entry;
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

  String? _normalizeComment(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

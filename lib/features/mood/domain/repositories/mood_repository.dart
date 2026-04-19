import '../../../../core/utils/result.dart';
import '../entities/mood_entry.dart';

abstract class MoodRepository {
  Future<Result<MoodEntry?>> getTodayMoodEntry();
  Future<Result<List<MoodEntry>>> getMoodHistory();
  Future<Result<MoodEntry>> saveMoodEntry({
    required int moodValue,
    String? comment,
  });
}

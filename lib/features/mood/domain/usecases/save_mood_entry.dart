import '../../../../core/utils/result.dart';
import '../entities/mood_entry.dart';
import '../repositories/mood_repository.dart';

class SaveMoodEntry {
  const SaveMoodEntry(this._repository);

  final MoodRepository _repository;

  Future<Result<MoodEntry>> call({required int moodValue, String? comment}) {
    return _repository.saveMoodEntry(moodValue: moodValue, comment: comment);
  }
}

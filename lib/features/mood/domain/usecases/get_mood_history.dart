import '../../../../core/utils/result.dart';
import '../entities/mood_entry.dart';
import '../repositories/mood_repository.dart';

class GetMoodHistory {
  const GetMoodHistory(this._repository);

  final MoodRepository _repository;

  Future<Result<List<MoodEntry>>> call() => _repository.getMoodHistory();
}

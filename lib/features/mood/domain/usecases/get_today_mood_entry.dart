import '../../../../core/utils/result.dart';
import '../entities/mood_entry.dart';
import '../repositories/mood_repository.dart';

class GetTodayMoodEntry {
  const GetTodayMoodEntry(this._repository);

  final MoodRepository _repository;

  Future<Result<MoodEntry?>> call() => _repository.getTodayMoodEntry();
}

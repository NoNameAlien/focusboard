import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/mood_entry.dart';
import '../../domain/repositories/mood_repository.dart';
import '../datasources/mood_local_data_source.dart';

class MoodRepositoryImpl implements MoodRepository {
  const MoodRepositoryImpl(this._localDataSource);

  final MoodLocalDataSource _localDataSource;

  @override
  Future<Result<MoodEntry?>> getTodayMoodEntry() async {
    try {
      final entry = await _localDataSource.getTodayMoodEntry();
      return Result.ok<MoodEntry?>(entry?.toEntity());
    } on Failure catch (failure) {
      return Result.err<MoodEntry?>(failure);
    } catch (_) {
      return Result.err<MoodEntry?>(
        const Failure('Failed to load today mood entry.'),
      );
    }
  }

  @override
  Future<Result<List<MoodEntry>>> getMoodHistory() async {
    try {
      final entries = await _localDataSource.getMoodHistory();
      return Result.ok<List<MoodEntry>>(
        entries.map((entry) => entry.toEntity()).toList(growable: false),
      );
    } on Failure catch (failure) {
      return Result.err<List<MoodEntry>>(failure);
    } catch (_) {
      return Result.err<List<MoodEntry>>(
        const Failure('Failed to load mood history.'),
      );
    }
  }

  @override
  Future<Result<MoodEntry>> saveMoodEntry({
    required int moodValue,
    String? comment,
  }) async {
    try {
      final entry = await _localDataSource.saveMoodEntry(
        moodValue: moodValue,
        comment: comment,
      );
      return Result.ok<MoodEntry>(entry.toEntity());
    } on Failure catch (failure) {
      return Result.err<MoodEntry>(failure);
    } catch (_) {
      return Result.err<MoodEntry>(const Failure('Failed to save mood entry.'));
    }
  }
}

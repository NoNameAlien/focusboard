import '../../../core/storage/app_storage.dart';
import '../../../features/mood/data/datasources/mood_local_data_source.dart';
import '../../../features/mood/data/repositories/mood_repository_impl.dart';
import '../../../features/mood/domain/repositories/mood_repository.dart';
import '../../../features/mood/domain/usecases/get_mood_history.dart';
import '../../../features/mood/domain/usecases/get_today_mood_entry.dart';
import '../../../features/mood/domain/usecases/save_mood_entry.dart';
import '../../../features/mood/presentation/controller/mood_controller.dart';

class MoodModule {
  MoodModule({
    required this.moodLocalDataSource,
    required this.moodRepository,
    required this.getTodayMoodEntry,
    required this.getMoodHistory,
    required this.saveMoodEntry,
    required this.moodController,
  });

  final MoodLocalDataSource moodLocalDataSource;
  final MoodRepository moodRepository;
  final GetTodayMoodEntry getTodayMoodEntry;
  final GetMoodHistory getMoodHistory;
  final SaveMoodEntry saveMoodEntry;
  final MoodController moodController;

  static Future<MoodModule> create({required AppStorage storage}) async {
    final moodLocalDataSource = FileMoodLocalDataSource(storage);
    await moodLocalDataSource.initialize();

    final moodRepository = MoodRepositoryImpl(moodLocalDataSource);
    final getTodayMoodEntry = GetTodayMoodEntry(moodRepository);
    final getMoodHistory = GetMoodHistory(moodRepository);
    final saveMoodEntry = SaveMoodEntry(moodRepository);
    final moodController = MoodController(
      getTodayMoodEntry: getTodayMoodEntry,
      getMoodHistory: getMoodHistory,
      saveMoodEntry: saveMoodEntry,
    );

    return MoodModule(
      moodLocalDataSource: moodLocalDataSource,
      moodRepository: moodRepository,
      getTodayMoodEntry: getTodayMoodEntry,
      getMoodHistory: getMoodHistory,
      saveMoodEntry: saveMoodEntry,
      moodController: moodController,
    );
  }
}

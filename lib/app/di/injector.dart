import '../../core/storage/app_storage.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/presentation/controller/auth_controller.dart';
import '../../features/habits/data/datasources/habit_completion_local_data_source.dart';
import '../../features/habits/data/datasources/habits_local_data_source.dart';
import '../../features/habits/domain/repositories/habit_completion_repository.dart';
import '../../features/habits/domain/repositories/habit_repository.dart';
import '../../features/habits/domain/usecases/create_habit.dart';
import '../../features/habits/domain/usecases/delete_habit.dart';
import '../../features/habits/domain/usecases/get_habit_by_id.dart';
import '../../features/habits/domain/usecases/get_habits.dart';
import '../../features/habits/domain/usecases/get_today_completions.dart';
import '../../features/habits/domain/usecases/mark_habit_completed.dart';
import '../../features/habits/domain/usecases/unmark_habit_completed.dart';
import '../../features/habits/domain/usecases/update_habit.dart';
import '../../features/habits/presentation/controller/habits_controller.dart';
import '../../features/mood/data/datasources/mood_local_data_source.dart';
import '../../features/mood/domain/repositories/mood_repository.dart';
import '../../features/mood/domain/usecases/get_mood_history.dart';
import '../../features/mood/domain/usecases/get_today_mood_entry.dart';
import '../../features/mood/domain/usecases/save_mood_entry.dart';
import '../../features/mood/presentation/controller/mood_controller.dart';
import 'modules/auth_module.dart';
import 'modules/habits_module.dart';
import 'modules/mood_module.dart';

late final AppDependencies dependencies;

Future<void> setupDependency() async {
  dependencies = await AppDependencies.create();
}

class AppDependencies {
  AppDependencies({
    required this.storage,
    required this.auth,
    required this.habits,
    required this.mood,
  });

  final AppStorage storage;
  final AuthModule auth;
  final HabitsModule habits;
  final MoodModule mood;

  AuthLocalDataSource get authLocalDataSource => auth.dataSource;
  AuthRepository get authRepository => auth.repository;
  GetCurrentUser get getCurrentUser => auth.getCurrentUser;
  SignIn get signIn => auth.signIn;
  SignOut get signOut => auth.signOut;
  SignUp get signUp => auth.signUp;
  AuthController get authController => auth.authController;

  HabitsLocalDataSource get habitsLocalDataSource =>
      habits.habitsLocalDataSource;
  HabitRepository get habitRepository => habits.habitRepository;
  HabitCompletionLocalDataSource get habitCompletionLocalDataSource =>
      habits.habitCompletionLocalDataSource;
  HabitCompletionRepository get habitCompletionRepository =>
      habits.habitCompletionRepository;
  GetHabits get getHabits => habits.getHabits;
  GetHabitById get getHabitById => habits.getHabitById;
  CreateHabit get createHabit => habits.createHabit;
  UpdateHabit get updateHabit => habits.updateHabit;
  DeleteHabit get deleteHabit => habits.deleteHabit;
  GetTodayCompletions get getTodayCompletions => habits.getTodayCompletions;
  MarkHabitCompleted get markHabitCompleted => habits.markHabitCompleted;
  UnmarkHabitCompleted get unmarkHabitCompleted => habits.unmarkHabitCompleted;
  HabitsController get habitsController => habits.habitsController;

  MoodLocalDataSource get moodLocalDataSource => mood.moodLocalDataSource;
  MoodRepository get moodRepository => mood.moodRepository;
  GetTodayMoodEntry get getTodayMoodEntry => mood.getTodayMoodEntry;
  GetMoodHistory get getMoodHistory => mood.getMoodHistory;
  SaveMoodEntry get saveMoodEntry => mood.saveMoodEntry;
  MoodController get moodController => mood.moodController;

  static Future<AppDependencies> create() async {
    final storage = await AppStorage.initialize();
    final auth = await AuthModule.create(storage: storage);
    final habits = await HabitsModule.create(storage: storage);
    final mood = await MoodModule.create(storage: storage);

    return AppDependencies(
      storage: storage,
      auth: auth,
      habits: habits,
      mood: mood,
    );
  }
}

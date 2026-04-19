import '../../../core/storage/app_storage.dart';
import '../../../features/habits/data/datasources/habit_completion_local_data_source.dart';
import '../../../features/habits/data/datasources/habits_local_data_source.dart';
import '../../../features/habits/data/repositories/habit_completion_repository_impl.dart';
import '../../../features/habits/data/repositories/habit_repository_impl.dart';
import '../../../features/habits/domain/repositories/habit_completion_repository.dart';
import '../../../features/habits/domain/repositories/habit_repository.dart';
import '../../../features/habits/domain/usecases/create_habit.dart';
import '../../../features/habits/domain/usecases/delete_habit.dart';
import '../../../features/habits/domain/usecases/get_habit_by_id.dart';
import '../../../features/habits/domain/usecases/get_habits.dart';
import '../../../features/habits/domain/usecases/get_today_completions.dart';
import '../../../features/habits/domain/usecases/mark_habit_completed.dart';
import '../../../features/habits/domain/usecases/unmark_habit_completed.dart';
import '../../../features/habits/domain/usecases/update_habit.dart';
import '../../../features/habits/presentation/controller/habits_controller.dart';

class HabitsModule {
  HabitsModule({
    required this.habitsLocalDataSource,
    required this.habitCompletionLocalDataSource,
    required this.habitRepository,
    required this.habitCompletionRepository,
    required this.getHabits,
    required this.getHabitById,
    required this.createHabit,
    required this.updateHabit,
    required this.deleteHabit,
    required this.getTodayCompletions,
    required this.markHabitCompleted,
    required this.unmarkHabitCompleted,
    required this.habitsController,
  });

  final HabitsLocalDataSource habitsLocalDataSource;
  final HabitCompletionLocalDataSource habitCompletionLocalDataSource;
  final HabitRepository habitRepository;
  final HabitCompletionRepository habitCompletionRepository;
  final GetHabits getHabits;
  final GetHabitById getHabitById;
  final CreateHabit createHabit;
  final UpdateHabit updateHabit;
  final DeleteHabit deleteHabit;
  final GetTodayCompletions getTodayCompletions;
  final MarkHabitCompleted markHabitCompleted;
  final UnmarkHabitCompleted unmarkHabitCompleted;
  final HabitsController habitsController;

  static Future<HabitsModule> create({required AppStorage storage}) async {
    final habitsLocalDataSource = FileHabitsLocalDataSource(storage);
    final habitCompletionLocalDataSource = FileHabitCompletionLocalDataSource(
      storage,
    );
    await habitsLocalDataSource.initialize();
    await habitCompletionLocalDataSource.initialize();

    final habitRepository = HabitRepositoryImpl(
      habitsLocalDataSource,
      habitCompletionLocalDataSource,
    );
    final habitCompletionRepository = HabitCompletionRepositoryImpl(
      habitCompletionLocalDataSource,
    );
    final getHabits = GetHabits(habitRepository);
    final getHabitById = GetHabitById(habitRepository);
    final createHabit = CreateHabit(habitRepository);
    final updateHabit = UpdateHabit(habitRepository);
    final deleteHabit = DeleteHabit(habitRepository);
    final getTodayCompletions = GetTodayCompletions(habitCompletionRepository);
    final markHabitCompleted = MarkHabitCompleted(habitCompletionRepository);
    final unmarkHabitCompleted = UnmarkHabitCompleted(
      habitCompletionRepository,
    );
    final habitsController = HabitsController(
      getHabits: getHabits,
      createHabit: createHabit,
      getTodayCompletions: getTodayCompletions,
      markHabitCompleted: markHabitCompleted,
      unmarkHabitCompleted: unmarkHabitCompleted,
    );

    return HabitsModule(
      habitsLocalDataSource: habitsLocalDataSource,
      habitCompletionLocalDataSource: habitCompletionLocalDataSource,
      habitRepository: habitRepository,
      habitCompletionRepository: habitCompletionRepository,
      getHabits: getHabits,
      getHabitById: getHabitById,
      createHabit: createHabit,
      updateHabit: updateHabit,
      deleteHabit: deleteHabit,
      getTodayCompletions: getTodayCompletions,
      markHabitCompleted: markHabitCompleted,
      unmarkHabitCompleted: unmarkHabitCompleted,
      habitsController: habitsController,
    );
  }
}

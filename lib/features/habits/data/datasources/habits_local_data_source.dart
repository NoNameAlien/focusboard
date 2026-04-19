import '../../../../core/error/failures.dart';
import '../../../../core/storage/app_storage.dart';
import '../../../../core/storage/json_store.dart';
import '../dto/habit_dto.dart';

abstract class HabitsLocalDataSource {
  Future<void> initialize();
  Future<List<HabitDto>> getHabits();
  Future<HabitDto> getHabitById(String id);
  Future<HabitDto> createHabit({
    required String title,
    String? description,
    int? color,
    int? icon,
  });
  Future<HabitDto> updateHabit({
    required String id,
    required String title,
    String? description,
    int? color,
    int? icon,
  });
  Future<void> deleteHabit(String id);
}

class FileHabitsLocalDataSource implements HabitsLocalDataSource {
  FileHabitsLocalDataSource(AppStorage storage)
    : _store = JsonListStore<HabitDto>(
        storage: storage,
        fileName: 'habits.json',
        fromJson: HabitDto.fromJson,
        toJson: (value) => value.toJson(),
      );

  final JsonListStore<HabitDto> _store;

  @override
  Future<void> initialize() async {
    final existing = await _store.readAll();
    if (existing.isNotEmpty) {
      return;
    }

    final seedHabits = [
      HabitDto(
        id: 'habit_1',
        title: 'Morning walk',
        description: 'Walk for at least 20 minutes before work.',
        color: 0xFF4A7C59,
        icon: 0xe318,
        createdAt: DateTime(2026, 4, 10, 8),
        updatedAt: DateTime(2026, 4, 10, 8),
      ),
      HabitDto(
        id: 'habit_2',
        title: 'Read 10 pages',
        description: 'Read a book before bed.',
        color: 0xFFD98E04,
        icon: 0xe0ef,
        createdAt: DateTime(2026, 4, 12, 21),
        updatedAt: DateTime(2026, 4, 12, 21),
      ),
    ];

    await _store.writeAll(seedHabits);
  }

  @override
  Future<List<HabitDto>> getHabits() {
    return _store.readAll();
  }

  @override
  Future<HabitDto> getHabitById(String id) async {
    final habits = await _store.readAll();
    try {
      return habits.firstWhere((habit) => habit.id == id);
    } catch (_) {
      throw const Failure('Habit not found.');
    }
  }

  @override
  Future<HabitDto> createHabit({
    required String title,
    String? description,
    int? color,
    int? icon,
  }) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw const Failure('Habit title cannot be empty.');
    }

    final habits = await _store.readAll();
    final now = DateTime.now();
    final habit = HabitDto(
      id: 'habit_${now.microsecondsSinceEpoch}',
      title: normalizedTitle,
      description: _normalizeDescription(description),
      color: color,
      icon: icon,
      createdAt: now,
      updatedAt: now,
    );

    await _store.writeAll([habit, ...habits]);
    return habit;
  }

  @override
  Future<HabitDto> updateHabit({
    required String id,
    required String title,
    String? description,
    int? color,
    int? icon,
  }) async {
    final normalizedTitle = title.trim();
    if (normalizedTitle.isEmpty) {
      throw const Failure('Habit title cannot be empty.');
    }

    final habits = await _store.readAll();
    final index = habits.indexWhere((habit) => habit.id == id);
    if (index == -1) {
      throw const Failure('Habit not found.');
    }

    final current = habits[index];
    final updated = HabitDto(
      id: current.id,
      title: normalizedTitle,
      description: _normalizeDescription(description),
      color: color ?? current.color,
      icon: icon ?? current.icon,
      createdAt: current.createdAt,
      updatedAt: DateTime.now(),
    );

    final nextHabits = [...habits]..[index] = updated;
    await _store.writeAll(nextHabits);
    return updated;
  }

  @override
  Future<void> deleteHabit(String id) async {
    final habits = await _store.readAll();
    final nextHabits = habits.where((habit) => habit.id != id).toList();
    if (nextHabits.length == habits.length) {
      throw const Failure('Habit not found.');
    }
    await _store.writeAll(nextHabits);
  }

  String? _normalizeDescription(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}

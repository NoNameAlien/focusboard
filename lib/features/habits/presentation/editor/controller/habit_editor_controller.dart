import 'package:flutter/foundation.dart';

import '../../../domain/entities/habit.dart';
import '../../../domain/usecases/create_habit.dart';
import '../../../domain/usecases/update_habit.dart';
import '../habit_editor_state.dart';

class HabitEditorController extends ChangeNotifier {
  HabitEditorController({
    required CreateHabit createHabit,
    required UpdateHabit updateHabit,
  }) : _createHabit = createHabit,
       _updateHabit = updateHabit;

  final CreateHabit _createHabit;
  final UpdateHabit _updateHabit;

  HabitEditorState _state = const HabitEditorState.initial();

  HabitEditorState get state => _state;

  void initialize({Habit? habit}) {
    _emit(HabitEditorState(status: HabitEditorStatus.ready, habit: habit));
  }

  Future<Habit?> submit({
    String? id,
    required String title,
    String? description,
  }) async {
    _emit(
      _state.copyWith(status: HabitEditorStatus.submitting, clearMessage: true),
    );

    final result = id == null
        ? await _createHabit(title: title, description: description)
        : await _updateHabit(id: id, title: title, description: description);

    if (result.isFailure || result.data == null) {
      _emit(
        _state.copyWith(
          status: HabitEditorStatus.failure,
          message: result.failure?.message ?? 'Failed to save habit.',
        ),
      );
      return null;
    }

    final habit = result.data!;
    _emit(
      _state.copyWith(
        status: HabitEditorStatus.success,
        habit: habit,
        clearMessage: true,
      ),
    );
    return habit;
  }

  void _emit(HabitEditorState state) {
    _state = state;
    notifyListeners();
  }
}

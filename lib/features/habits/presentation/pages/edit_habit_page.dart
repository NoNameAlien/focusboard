import 'package:flutter/material.dart';

import '../../../../app/di/injector.dart';
import '../../domain/entities/habit.dart';
import '../editor/controller/habit_editor_controller.dart';
import '../widgets/habit_form_fields.dart';

class EditHabitPage extends StatefulWidget {
  const EditHabitPage({super.key, required this.habit});

  static const String routeName = '/habits/edit';

  final Habit habit;

  @override
  State<EditHabitPage> createState() => _EditHabitPageState();
}

class _EditHabitPageState extends State<EditHabitPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final HabitEditorController _editorController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.habit.title);
    _descriptionController = TextEditingController(
      text: widget.habit.description ?? '',
    );
    _editorController = HabitEditorController(
      createHabit: dependencies.createHabit,
      updateHabit: dependencies.updateHabit,
    )..initialize(habit: widget.habit);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _editorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final habit = await _editorController.submit(
      id: widget.habit.id,
      title: _titleController.text,
      description: _descriptionController.text,
    );

    if (!mounted || habit == null) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _editorController,
      builder: (context, _) {
        final state = _editorController.state;

        return Scaffold(
          appBar: AppBar(title: const Text('Edit habit')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    HabitFormFields(
                      titleController: _titleController,
                      descriptionController: _descriptionController,
                    ),
                    if (state.message != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        state.message!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: state.isSubmitting ? null : _submit,
                      child: state.isSubmitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Save changes'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

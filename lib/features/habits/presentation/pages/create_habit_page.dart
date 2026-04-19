import 'package:flutter/material.dart';

import '../../../../app/di/injector.dart';
import '../editor/controller/habit_editor_controller.dart';
import '../widgets/habit_form_fields.dart';

class CreateHabitPage extends StatefulWidget {
  const CreateHabitPage({super.key});

  static const String routeName = '/habits/create';

  @override
  State<CreateHabitPage> createState() => _CreateHabitPageState();
}

class _CreateHabitPageState extends State<CreateHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late final HabitEditorController _editorController;

  @override
  void initState() {
    super.initState();
    _editorController = HabitEditorController(
      createHabit: dependencies.createHabit,
      updateHabit: dependencies.updateHabit,
    )..initialize();
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
          appBar: AppBar(title: const Text('Create habit')),
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
                          : const Text('Create habit'),
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

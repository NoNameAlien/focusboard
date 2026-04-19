import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../controller/mood_controller.dart';

class MoodCheckInPage extends StatefulWidget {
  const MoodCheckInPage({super.key});

  static const String routeName = '/mood/check-in';

  @override
  State<MoodCheckInPage> createState() => _MoodCheckInPageState();
}

class _MoodCheckInPageState extends State<MoodCheckInPage> {
  final _commentController = TextEditingController();
  int? _selectedMoodValue;
  late MoodController _moodController;
  bool _didInitDependencies = false;

  static const _moodOptions = <({int value, String emoji, String label})>[
    (value: 1, emoji: '😞', label: 'Very low'),
    (value: 2, emoji: '🙁', label: 'Low'),
    (value: 3, emoji: '😐', label: 'Okay'),
    (value: 4, emoji: '🙂', label: 'Good'),
    (value: 5, emoji: '😄', label: 'Great'),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitDependencies) {
      return;
    }

    _moodController = context.moodController;
    final todayEntry = _moodController.state.todayEntry;
    _selectedMoodValue = todayEntry?.moodValue;
    _commentController.text = todayEntry?.comment ?? '';
    _didInitDependencies = true;
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final moodValue = _selectedMoodValue;
    if (moodValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose your mood for today.')),
      );
      return;
    }

    final entry = await _moodController.saveMoodEntry(
      moodValue: moodValue,
      comment: _commentController.text,
    );

    if (!mounted || entry == null) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _moodController,
      builder: (context, _) {
        final state = _moodController.state;

        return Scaffold(
          appBar: AppBar(title: const Text('Mood check-in')),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'How do you feel today?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _moodOptions
                      .map((option) {
                        final selected = _selectedMoodValue == option.value;
                        return ChoiceChip(
                          label: Text('${option.emoji} ${option.label}'),
                          selected: selected,
                          onSelected: (_) {
                            setState(() {
                              _selectedMoodValue = option.value;
                            });
                          },
                        );
                      })
                      .toList(growable: false),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _commentController,
                  minLines: 3,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Comment',
                    border: OutlineInputBorder(),
                  ),
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
                  onPressed: state.isSaving ? null : _submit,
                  child: state.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save mood'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

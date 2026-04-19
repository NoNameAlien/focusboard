import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../domain/entities/mood_entry.dart';
import '../controller/mood_controller.dart';

class MoodHistoryPage extends StatefulWidget {
  const MoodHistoryPage({super.key});

  static const String routeName = '/mood/history';

  @override
  State<MoodHistoryPage> createState() => _MoodHistoryPageState();
}

class _MoodHistoryPageState extends State<MoodHistoryPage> {
  late MoodController _moodController;
  bool _didInitDependencies = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInitDependencies) {
      return;
    }

    _moodController = context.moodController;
    _didInitDependencies = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _moodController.loadMoodData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _moodController,
      builder: (context, _) {
        final state = _moodController.state;

        return Scaffold(
          appBar: AppBar(title: const Text('Mood history')),
          body: RefreshIndicator(
            onRefresh: _moodController.loadMoodData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                if (state.isLoading) ...[
                  const SizedBox(height: 120),
                  const Center(child: CircularProgressIndicator()),
                ] else if (state.history.isEmpty) ...[
                  const SizedBox(height: 120),
                  const Center(child: Text('No mood entries yet.')),
                ] else ...[
                  ...state.history.map(_MoodHistoryCard.new),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MoodHistoryCard extends StatelessWidget {
  const _MoodHistoryCard(this.entry);

  final MoodEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(child: Text(_emojiFor(entry.moodValue))),
        title: Text(_labelFor(entry.moodValue)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_formatDate(entry.date)),
            ),
            if (entry.comment != null && entry.comment!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(entry.comment!),
              ),
          ],
        ),
      ),
    );
  }

  String _emojiFor(int value) {
    switch (value) {
      case 1:
        return '😞';
      case 2:
        return '🙁';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '🙂';
    }
  }

  String _labelFor(int value) {
    switch (value) {
      case 1:
        return 'Very low';
      case 2:
        return 'Low';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Great';
      default:
        return 'Mood';
    }
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    return '$day.$month.$year';
  }
}

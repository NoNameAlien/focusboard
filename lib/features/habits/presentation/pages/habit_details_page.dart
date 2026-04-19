import 'package:flutter/material.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/habit.dart';

class HabitDetailsPage extends StatefulWidget {
  const HabitDetailsPage({super.key, required this.habitId});

  static const String routeName = '/habits/details';

  final String habitId;

  @override
  State<HabitDetailsPage> createState() => _HabitDetailsPageState();
}

class _HabitDetailsPageState extends State<HabitDetailsPage> {
  late Future<Result<Habit>> _habitFuture;
  bool _isDeleting = false;
  String? _deleteError;

  @override
  void initState() {
    super.initState();
    _habitFuture = dependencies.getHabitById(widget.habitId);
  }

  Future<void> _reload() async {
    setState(() {
      _habitFuture = dependencies.getHabitById(widget.habitId);
      _deleteError = null;
    });
  }

  Future<void> _openEdit(Habit habit) async {
    final edited = await context.pushEditHabit(habit);
    if (!mounted || edited != true) {
      return;
    }

    await _reload();
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete habit?'),
          content: const Text('This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isDeleting = true;
      _deleteError = null;
    });

    final result = await dependencies.deleteHabit(widget.habitId);
    if (!mounted) {
      return;
    }

    if (result.isFailure) {
      setState(() {
        _isDeleting = false;
        _deleteError = result.failure?.message ?? 'Failed to delete habit.';
      });
      return;
    }

    Navigator.of(context).pop(HabitDetailsResult.deleted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit details')),
      body: FutureBuilder<Result<Habit>>(
        future: _habitFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final result = snapshot.data!;
          if (result.isFailure || result.data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      result.failure?.message ??
                          'Failed to load habit details.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _reload,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final habit = result.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                Text(
                  habit.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  habit.description?.isNotEmpty == true
                      ? habit.description!
                      : 'No description yet.',
                ),
                const SizedBox(height: 24),
                Text('Created: ${_formatDateTime(habit.createdAt)}'),
                const SizedBox(height: 8),
                Text('Updated: ${_formatDateTime(habit.updatedAt)}'),
                const SizedBox(height: 16),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.pending_actions_outlined),
                  title: Text('Completion status'),
                  subtitle: Text('Coming soon'),
                ),
                if (_deleteError != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _deleteError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _isDeleting ? null : () => _openEdit(habit),
                  child: const Text('Edit'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _isDeleting ? null : _delete,
                  child: _isDeleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Delete'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    final year = value.year.toString();
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$day.$month.$year $hour:$minute';
  }
}

enum HabitDetailsResult { deleted }

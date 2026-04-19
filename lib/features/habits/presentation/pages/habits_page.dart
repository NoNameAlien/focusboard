import 'package:flutter/material.dart';

import '../../../../app/app.dart';
import '../../../../app/router/app_router.dart';
import '../../../auth/presentation/controller/auth_controller.dart';
import '../../../auth/presentation/controller/auth_state.dart';
import '../../../mood/presentation/controller/mood_controller.dart';
import '../../../mood/presentation/controller/mood_state.dart';
import '../../domain/entities/habit.dart';
import '../controller/habits_controller.dart';
import '../controller/habits_state.dart';
import 'habit_details_page.dart';

class HabitsPage extends StatefulWidget {
  const HabitsPage({super.key});

  static const String routeName = '/home';

  @override
  State<HabitsPage> createState() => _HabitsPageState();
}

class _HabitsPageState extends State<HabitsPage> {
  late final VoidCallback _authListener;
  late final AuthController _authController;
  late final HabitsController _habitsController;
  late final MoodController _moodController;
  bool _isSubscribed = false;
  bool _habitsRequested = false;
  bool _moodRequested = false;

  @override
  void initState() {
    super.initState();
    _authListener = _handleAuthChanges;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isSubscribed) {
      return;
    }

    _authController = context.authController;
    _habitsController = context.habitsController;
    _moodController = context.moodController;
    _authController.addListener(_authListener);
    _isSubscribed = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (!_habitsRequested) {
        _habitsRequested = true;
        _habitsController.loadHabits();
      }
      if (!_moodRequested) {
        _moodRequested = true;
        _moodController.loadMoodData();
      }
    });
  }

  @override
  void dispose() {
    if (_isSubscribed) {
      _authController.removeListener(_authListener);
    }
    super.dispose();
  }

  void _handleAuthChanges() {
    if (!mounted) {
      return;
    }

    if (_authController.state is AuthUnauthenticatedState) {
      context.resetToLogin();
    }
  }

  Future<void> _openCreateHabitPage() async {
    final created = await context.pushCreateHabit();
    if (!mounted || created != true) {
      return;
    }

    await _habitsController.loadHabits();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Habit created.')));
  }

  Future<void> _openHabitDetails(Habit habit) async {
    final result = await context.pushHabitDetails(habit.id);

    if (!mounted) {
      return;
    }

    if (result == true) {
      await _habitsController.loadHabits();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Habit updated.')));
    } else if (result == HabitDetailsResult.deleted) {
      await _habitsController.loadHabits();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Habit deleted.')));
    }
  }

  Future<void> _openMoodCheckInPage() async {
    final saved = await context.pushMoodCheckIn();
    if (!mounted || saved != true) {
      return;
    }

    await _moodController.loadMoodData();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Mood saved.')));
  }

  Future<void> _openMoodHistoryPage() async {
    await context.pushMoodHistory();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _authController,
        _habitsController,
        _moodController,
      ]),
      builder: (context, _) {
        final authState = _authController.state;
        final habitsState = _habitsController.state;
        final moodState = _moodController.state;
        final user = authState.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Habits'),
            actions: [
              IconButton(
                onPressed: authState.isLoading ? null : _authController.signOut,
                icon: authState.isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.logout),
                tooltip: 'Logout',
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openCreateHabitPage,
            icon: const Icon(Icons.add),
            label: const Text('Create habit'),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await _habitsController.loadHabits();
              await _moodController.loadMoodData();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              children: [
                if (user != null) ...[
                  Text(
                    'Signed in as ${user.name}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(user.email),
                  const SizedBox(height: 20),
                ],
                _DailySummaryCard(
                  habitsState: habitsState,
                  moodState: moodState,
                  onMoodCheckInTap: _openMoodCheckInPage,
                  onMoodHistoryTap: _openMoodHistoryPage,
                ),
                const SizedBox(height: 24),
                ..._buildBody(context, habitsState),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildBody(BuildContext context, HabitsState state) {
    if (state is HabitsInitialState || state is HabitsLoadingState) {
      return const [
        SizedBox(height: 120),
        Center(child: CircularProgressIndicator()),
      ];
    }

    if (state is HabitsEmptyState) {
      return const [_EmptyHabitsState()];
    }

    if (state is HabitsFailureState) {
      return [
        _FailureHabitsState(
          message: state.message,
          onRetry: _habitsController.loadHabits,
        ),
      ];
    }

    if (state is HabitsLoadedState) {
      return [
        if (state.message != null) ...[
          Text(
            state.message!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 12),
        ],
        ...state.habits.map(
          (habit) => _HabitCard(
            habit: habit,
            isCompletedToday: state.isHabitCompletedToday(habit.id),
            isUpdating: state.isHabitUpdating(habit.id),
            onTap: () => _openHabitDetails(habit),
            onToggleCompletion: () =>
                _habitsController.toggleHabitCompletion(habit.id),
          ),
        ),
      ];
    }

    return const [];
  }
}

class _DailySummaryCard extends StatelessWidget {
  const _DailySummaryCard({
    required this.habitsState,
    required this.moodState,
    required this.onMoodCheckInTap,
    required this.onMoodHistoryTap,
  });

  final HabitsState habitsState;
  final MoodState moodState;
  final VoidCallback onMoodCheckInTap;
  final VoidCallback onMoodHistoryTap;

  @override
  Widget build(BuildContext context) {
    final percent = (habitsState.completionRate * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily summary', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _SummaryMetric(
                label: 'Total habits',
                value: '${habitsState.totalHabits}',
              ),
              _SummaryMetric(
                label: 'Completed today',
                value: '${habitsState.completedTodayCount}',
              ),
              _SummaryMetric(label: 'Daily progress', value: '$percent%'),
              _SummaryMetric(
                label: 'Mood today',
                value: moodState.hasMoodToday ? 'Logged' : 'Missing',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.tonal(
                onPressed: onMoodCheckInTap,
                child: Text(
                  moodState.hasMoodToday ? 'Update mood' : 'Check in mood',
                ),
              ),
              OutlinedButton(
                onPressed: onMoodHistoryTap,
                child: const Text('Mood history'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.habit,
    required this.isCompletedToday,
    required this.isUpdating,
    required this.onTap,
    required this.onToggleCompletion,
  });

  final Habit habit;
  final bool isCompletedToday;
  final bool isUpdating;
  final VoidCallback onTap;
  final VoidCallback onToggleCompletion;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          isCompletedToday ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isCompletedToday ? Colors.green : null,
        ),
        title: Text(habit.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (habit.description != null && habit.description!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(habit.description!),
              ),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                isCompletedToday ? 'Completed today' : 'Not completed today',
                style: TextStyle(
                  color: isCompletedToday ? Colors.green : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: isUpdating
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : IconButton(
                onPressed: onToggleCompletion,
                icon: Icon(isCompletedToday ? Icons.undo : Icons.done),
                tooltip: isCompletedToday ? 'Unmark today' : 'Mark completed',
              ),
      ),
    );
  }
}

class _EmptyHabitsState extends StatelessWidget {
  const _EmptyHabitsState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 56),
            SizedBox(height: 16),
            Text(
              'No habits yet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('Create your first habit to start building momentum.'),
          ],
        ),
      ),
    );
  }
}

class _FailureHabitsState extends StatelessWidget {
  const _FailureHabitsState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 56,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../features/auth/presentation/controller/auth_controller.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/habits/domain/entities/habit.dart';
import '../../features/habits/presentation/pages/create_habit_page.dart';
import '../../features/habits/presentation/pages/edit_habit_page.dart';
import '../../features/habits/presentation/pages/habit_details_page.dart';
import '../../features/habits/presentation/pages/habits_page.dart';
import '../../features/mood/presentation/pages/mood_check_in_page.dart';
import '../../features/mood/presentation/pages/mood_history_page.dart';
import 'auth_guard.dart';

class AppRouter {
  AppRouter({required AuthController authController})
    : _authController = authController;

  static const String splash = SplashPage.routeName;
  static const String login = LoginPage.routeName;
  static const String register = RegisterPage.routeName;
  static const String home = HabitsPage.routeName;
  static const String createHabit = CreateHabitPage.routeName;
  static const String habitDetails = HabitDetailsPage.routeName;
  static const String editHabit = EditHabitPage.routeName;
  static const String moodCheckIn = MoodCheckInPage.routeName;
  static const String moodHistory = MoodHistoryPage.routeName;

  final AuthController _authController;

  Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? splash;
    final redirectedRouteName = AuthGuard.redirectFor(
      authState: _authController.state,
      routeName: routeName,
    );

    if (redirectedRouteName != null && redirectedRouteName != routeName) {
      return _buildRoute(
        _pageFor(redirectedRouteName, null),
        RouteSettings(name: redirectedRouteName),
      );
    }

    return _buildRoute(_pageFor(routeName, settings.arguments), settings);
  }

  Widget _pageFor(String routeName, Object? arguments) {
    switch (routeName) {
      case splash:
        return const SplashPage();
      case login:
        return const LoginPage();
      case register:
        return const RegisterPage();
      case home:
        return const HabitsPage();
      case createHabit:
        return const CreateHabitPage();
      case habitDetails:
        final args = arguments as HabitDetailsRouteArgs;
        return HabitDetailsPage(habitId: args.habitId);
      case editHabit:
        final args = arguments as EditHabitRouteArgs;
        return EditHabitPage(habit: args.habit);
      case moodCheckIn:
        return const MoodCheckInPage();
      case moodHistory:
        return const MoodHistoryPage();
      default:
        return const SplashPage();
    }
  }

  MaterialPageRoute<void> _buildRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute<void>(builder: (_) => page, settings: settings);
  }
}

class HabitDetailsRouteArgs {
  const HabitDetailsRouteArgs({required this.habitId});

  final String habitId;
}

class EditHabitRouteArgs {
  const EditHabitRouteArgs({required this.habit});

  final Habit habit;
}

extension AppNavigationX on BuildContext {
  Future<T?> pushLogin<T>() => Navigator.of(this).pushNamed<T>(AppRouter.login);

  Future<T?> pushRegister<T>() =>
      Navigator.of(this).pushNamed<T>(AppRouter.register);

  Future<T?> pushCreateHabit<T>() =>
      Navigator.of(this).pushNamed<T>(AppRouter.createHabit);

  Future<T?> pushHabitDetails<T>(String habitId) {
    return Navigator.of(this).pushNamed<T>(
      AppRouter.habitDetails,
      arguments: HabitDetailsRouteArgs(habitId: habitId),
    );
  }

  Future<T?> pushEditHabit<T>(Habit habit) {
    return Navigator.of(this).pushNamed<T>(
      AppRouter.editHabit,
      arguments: EditHabitRouteArgs(habit: habit),
    );
  }

  Future<T?> pushMoodCheckIn<T>() =>
      Navigator.of(this).pushNamed<T>(AppRouter.moodCheckIn);

  Future<T?> pushMoodHistory<T>() =>
      Navigator.of(this).pushNamed<T>(AppRouter.moodHistory);

  Future<T?> replaceWithHome<T>() =>
      Navigator.of(this).pushReplacementNamed<T, Object?>(AppRouter.home);

  Future<T?> replaceWithLogin<T>() =>
      Navigator.of(this).pushReplacementNamed<T, Object?>(AppRouter.login);

  Future<T?> resetToHome<T>() => Navigator.of(
    this,
  ).pushNamedAndRemoveUntil<T>(AppRouter.home, (route) => false);

  Future<T?> resetToLogin<T>() => Navigator.of(
    this,
  ).pushNamedAndRemoveUntil<T>(AppRouter.login, (route) => false);
}

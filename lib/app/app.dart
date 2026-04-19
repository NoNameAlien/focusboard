import 'package:flutter/material.dart';

import '../features/auth/presentation/controller/auth_controller.dart';
import '../features/habits/presentation/controller/habits_controller.dart';
import '../features/mood/presentation/controller/mood_controller.dart';
import 'di/injector.dart';
import 'router/app_router.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter(authController: dependencies.authController);

    return AppScope(
      authController: dependencies.authController,
      habitsController: dependencies.habitsController,
      moodController: dependencies.moodController,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'FocusBoard',
        initialRoute: AppRouter.splash,
        onGenerateRoute: appRouter.onGenerateRoute,
        theme: _buildTheme(),
      ),
    );
  }

  ThemeData _buildTheme() {
    const colorScheme = ColorScheme.light(
      primary: Color(0xFF1D5C4B),
      onPrimary: Color(0xFFF6F3EA),
      primaryContainer: Color(0xFFD7EBDD),
      onPrimaryContainer: Color(0xFF163C31),
      secondary: Color(0xFFB77937),
      onSecondary: Color(0xFFFFF8F1),
      secondaryContainer: Color(0xFFF3DFC8),
      onSecondaryContainer: Color(0xFF5E3A14),
      surface: Color(0xFFFFFBF5),
      onSurface: Color(0xFF1E2A25),
      error: Color(0xFFB43F32),
      onError: Color(0xFFFFFBFA),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF4EFE6),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1E2A25),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFFFFFBF5),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFFFFCF7),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD8CFC2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD8CFC2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF1D5C4B), width: 1.4),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.onSurface,
        contentTextStyle: const TextStyle(color: Color(0xFFFFFBF5)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.authController,
    required this.habitsController,
    required this.moodController,
    required super.child,
  });

  final AuthController authController;
  final HabitsController habitsController;
  final MoodController moodController;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is not found in the widget tree.');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) {
    return authController != oldWidget.authController ||
        habitsController != oldWidget.habitsController ||
        moodController != oldWidget.moodController;
  }
}

extension AppScopeX on BuildContext {
  AuthController get authController => AppScope.of(this).authController;
  HabitsController get habitsController => AppScope.of(this).habitsController;
  MoodController get moodController => AppScope.of(this).moodController;
}

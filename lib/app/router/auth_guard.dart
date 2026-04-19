import '../../features/auth/presentation/controller/auth_state.dart';
import 'app_router.dart';

class AuthGuard {
  const AuthGuard._();

  static bool requiresAuth(String routeName) {
    return routeName == AppRouter.home ||
        routeName == AppRouter.createHabit ||
        routeName == AppRouter.habitDetails ||
        routeName == AppRouter.editHabit ||
        routeName == AppRouter.moodCheckIn ||
        routeName == AppRouter.moodHistory;
  }

  static String? redirectFor({
    required AuthState authState,
    required String routeName,
  }) {
    if (routeName == AppRouter.splash) {
      return null;
    }

    if (authState.isAuthenticated &&
        (routeName == AppRouter.login || routeName == AppRouter.register)) {
      return AppRouter.home;
    }

    if (!authState.isAuthenticated && requiresAuth(routeName)) {
      return AppRouter.login;
    }

    return null;
  }
}

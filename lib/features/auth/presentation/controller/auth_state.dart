import '../../domain/entities/user_profile.dart';

sealed class AuthState {
  const AuthState();

  bool get isLoading =>
      this is AuthCheckingState || this is AuthSubmittingState;
  bool get isAuthenticated => this is AuthAuthenticatedState;
  bool get isUnauthenticated => this is AuthUnauthenticatedState;

  UserProfile? get user {
    final state = this;
    if (state is AuthAuthenticatedState) {
      return state.userProfile;
    }
    return null;
  }

  String? get message {
    final state = this;
    return switch (state) {
      AuthUnauthenticatedState(:final message) => message,
      AuthFailureState(:final message) => message,
      _ => null,
    };
  }
}

final class AuthInitialState extends AuthState {
  const AuthInitialState();
}

final class AuthCheckingState extends AuthState {
  const AuthCheckingState();
}

final class AuthSubmittingState extends AuthState {
  const AuthSubmittingState();
}

final class AuthAuthenticatedState extends AuthState {
  const AuthAuthenticatedState(this.userProfile);

  final UserProfile userProfile;
}

final class AuthUnauthenticatedState extends AuthState {
  const AuthUnauthenticatedState({this.message});

  @override
  final String? message;
}

final class AuthFailureState extends AuthState {
  const AuthFailureState(this.message);

  @override
  final String message;
}

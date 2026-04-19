import 'package:flutter/foundation.dart';

import '../../../../core/utils/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_state.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required GetCurrentUser getCurrentUser,
    required SignIn signIn,
    required SignOut signOut,
    required SignUp signUp,
  }) : _getCurrentUser = getCurrentUser,
       _signIn = signIn,
       _signOut = signOut,
       _signUp = signUp;

  final GetCurrentUser _getCurrentUser;
  final SignIn _signIn;
  final SignOut _signOut;
  final SignUp _signUp;

  AuthState _state = const AuthInitialState();

  AuthState get state => _state;

  Future<void> checkAuthState() async {
    _emit(const AuthCheckingState());

    final result = await _getCurrentUser();
    if (result.isFailure) {
      _emit(
        AuthUnauthenticatedState(
          message: result.failure?.message ?? 'Failed to restore session.',
        ),
      );
      return;
    }

    final user = result.data;
    if (user == null) {
      _emit(const AuthUnauthenticatedState());
      return;
    }

    _emit(AuthAuthenticatedState(user));
  }

  Future<void> signIn({required String email, required String password}) async {
    _emit(const AuthSubmittingState());

    final result = await _signIn(email: email, password: password);
    _handleUserResult(result, fallbackMessage: 'Failed to sign in.');
  }

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    _emit(const AuthSubmittingState());

    final result = await _signUp(name: name, email: email, password: password);
    _handleUserResult(result, fallbackMessage: 'Failed to register.');
  }

  Future<void> signOut() async {
    _emit(const AuthSubmittingState());

    final result = await _signOut();
    if (result.isFailure) {
      _emit(AuthFailureState(result.failure?.message ?? 'Failed to sign out.'));
      return;
    }

    _emit(const AuthUnauthenticatedState());
  }

  void clearMessage() {
    if (_state is AuthFailureState || _state is AuthUnauthenticatedState) {
      _emit(const AuthUnauthenticatedState());
    }
  }

  void _handleUserResult(
    Result<UserProfile> result, {
    required String fallbackMessage,
  }) {
    if (result.isFailure) {
      _emit(AuthFailureState(result.failure?.message ?? fallbackMessage));
      return;
    }

    final user = result.data;
    if (user == null) {
      _emit(AuthFailureState('Auth request returned an empty user.'));
      return;
    }

    _emit(AuthAuthenticatedState(user));
  }

  void _emit(AuthState state) {
    _state = state;
    notifyListeners();
  }
}

import '../../../../core/error/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../mappers/user_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._localDataSource);

  final AuthLocalDataSource _localDataSource;

  @override
  Future<Result<UserProfile?>> getCurrentUser() async {
    try {
      final user = await _localDataSource.getCurrentUser();
      return Result.ok<UserProfile?>(user?.toUserProfile());
    } on Failure catch (failure) {
      return Result.err<UserProfile?>(failure);
    } catch (_) {
      return Result.err<UserProfile?>(
        const Failure('Failed to load current user.'),
      );
    }
  }

  @override
  Future<Result<UserProfile>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await _localDataSource.signIn(
        email: email,
        password: password,
      );
      return Result.ok<UserProfile>(user.toUserProfile());
    } on Failure catch (failure) {
      return Result.err<UserProfile>(failure);
    } catch (_) {
      return Result.err<UserProfile>(const Failure('Failed to sign in.'));
    }
  }

  @override
  Future<Result<UserProfile>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final user = await _localDataSource.signUp(
        name: name,
        email: email,
        password: password,
      );
      return Result.ok<UserProfile>(user.toUserProfile());
    } on Failure catch (failure) {
      return Result.err<UserProfile>(failure);
    } catch (_) {
      return Result.err<UserProfile>(const Failure('Failed to register.'));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _localDataSource.signOut();
      return Result.ok<void>();
    } on Failure catch (failure) {
      return Result.err<void>(failure);
    } catch (_) {
      return Result.err<void>(const Failure('Failed to sign out.'));
    }
  }
}

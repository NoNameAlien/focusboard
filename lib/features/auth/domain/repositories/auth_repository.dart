import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';

abstract class AuthRepository {
  Future<Result<UserProfile?>> getCurrentUser();
  Future<Result<UserProfile>> signIn({
    required String email,
    required String password,
  });
  Future<Result<UserProfile>> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<Result<void>> signOut();
}

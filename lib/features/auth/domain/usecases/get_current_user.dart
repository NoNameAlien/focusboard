import '../../../../core/utils/result.dart';
import '../entities/user_profile.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  Future<Result<UserProfile?>> call() => _repository.getCurrentUser();
}

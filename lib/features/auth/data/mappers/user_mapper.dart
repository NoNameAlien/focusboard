import '../../domain/entities/user_profile.dart';
import '../dto/user_dto.dart';

extension UserDtoMapper on UserDto {
  UserProfile toUserProfile() => toEntity();
}

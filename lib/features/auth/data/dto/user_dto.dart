import '../../domain/entities/user_profile.dart';

class UserDto {
  const UserDto({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  final String id;
  final String name;
  final String email;
  final String password;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
  };

  UserProfile toEntity() => UserProfile(id: id, name: name, email: email);
}

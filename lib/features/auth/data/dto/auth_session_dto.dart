class AuthSessionDto {
  const AuthSessionDto({required this.userId});

  final String userId;

  factory AuthSessionDto.fromJson(Map<String, dynamic> json) {
    return AuthSessionDto(userId: json['userId'] as String);
  }

  Map<String, dynamic> toJson() => {'userId': userId};
}

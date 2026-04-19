import '../../../../core/error/failures.dart';
import '../../../../core/storage/app_storage.dart';
import '../../../../core/storage/json_store.dart';
import '../dto/auth_session_dto.dart';
import '../dto/user_dto.dart';

abstract class AuthLocalDataSource {
  Future<void> initialize();
  Future<UserDto?> getCurrentUser();
  Future<UserDto> signIn({required String email, required String password});
  Future<UserDto> signUp({
    required String name,
    required String email,
    required String password,
  });
  Future<void> signOut();
}

class FileAuthLocalDataSource implements AuthLocalDataSource {
  FileAuthLocalDataSource(AppStorage storage)
    : _usersStore = JsonListStore<UserDto>(
        storage: storage,
        fileName: 'auth_users.json',
        fromJson: UserDto.fromJson,
        toJson: (value) => value.toJson(),
      ),
      _sessionStore = JsonObjectStore<AuthSessionDto>(
        storage: storage,
        fileName: 'auth_session.json',
        fromJson: AuthSessionDto.fromJson,
        toJson: (value) => value.toJson(),
      );

  final JsonListStore<UserDto> _usersStore;
  final JsonObjectStore<AuthSessionDto> _sessionStore;

  @override
  Future<void> initialize() async {
    final users = await _usersStore.readAll();
    if (users.isNotEmpty) {
      return;
    }

    await _usersStore.writeAll(const [
      UserDto(
        id: '1',
        name: 'Demo User',
        email: 'demo@focusboard.dev',
        password: 'password123',
      ),
    ]);
  }

  @override
  Future<UserDto?> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final session = await _sessionStore.read();
    if (session == null) {
      return null;
    }

    final users = await _usersStore.readAll();
    final index = users.indexWhere((user) => user.id == session.userId);
    if (index == -1) {
      await _sessionStore.clear();
      return null;
    }

    return users[index];
  }

  @override
  Future<UserDto> signIn({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final normalizedEmail = email.trim().toLowerCase();
    final users = await _usersStore.readAll();
    final index = users.indexWhere((user) => user.email == normalizedEmail);
    if (index == -1 || users[index].password != password) {
      throw const Failure('Invalid email or password.');
    }

    final user = users[index];
    await _sessionStore.write(AuthSessionDto(userId: user.id));
    return user;
  }

  @override
  Future<UserDto> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));

    final normalizedName = name.trim();
    if (normalizedName.isEmpty) {
      throw const Failure('Name cannot be empty.');
    }

    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) {
      throw const Failure('Email cannot be empty.');
    }

    if (password.isEmpty) {
      throw const Failure('Password cannot be empty.');
    }

    final users = await _usersStore.readAll();
    final exists = users.any((user) => user.email == normalizedEmail);
    if (exists) {
      throw const Failure('Account with this email already exists.');
    }

    final user = UserDto(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: normalizedName,
      email: normalizedEmail,
      password: password,
    );

    await _usersStore.writeAll([user, ...users]);
    await _sessionStore.write(AuthSessionDto(userId: user.id));
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    await _sessionStore.clear();
  }
}

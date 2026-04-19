import '../../../core/storage/app_storage.dart';
import '../../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../features/auth/domain/usecases/get_current_user.dart';
import '../../../features/auth/domain/usecases/sign_in.dart';
import '../../../features/auth/domain/usecases/sign_out.dart';
import '../../../features/auth/domain/usecases/sign_up.dart';
import '../../../features/auth/presentation/controller/auth_controller.dart';

class AuthModule {
  AuthModule({
    required this.dataSource,
    required this.repository,
    required this.getCurrentUser,
    required this.signIn,
    required this.signOut,
    required this.signUp,
    required this.authController,
  });

  final AuthLocalDataSource dataSource;
  final AuthRepository repository;
  final GetCurrentUser getCurrentUser;
  final SignIn signIn;
  final SignOut signOut;
  final SignUp signUp;
  final AuthController authController;

  static Future<AuthModule> create({required AppStorage storage}) async {
    final dataSource = FileAuthLocalDataSource(storage);
    await dataSource.initialize();

    final repository = AuthRepositoryImpl(dataSource);
    final getCurrentUser = GetCurrentUser(repository);
    final signIn = SignIn(repository);
    final signOut = SignOut(repository);
    final signUp = SignUp(repository);
    final authController = AuthController(
      getCurrentUser: getCurrentUser,
      signIn: signIn,
      signOut: signOut,
      signUp: signUp,
    );

    return AuthModule(
      dataSource: dataSource,
      repository: repository,
      getCurrentUser: getCurrentUser,
      signIn: signIn,
      signOut: signOut,
      signUp: signUp,
      authController: authController,
    );
  }
}

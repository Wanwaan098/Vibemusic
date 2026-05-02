import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login(String email, String password) async {
    final user = await remoteDataSource.login(email, password);
    final role = await remoteDataSource.getRole(user.uid);

    return UserEntity(
      uid: user.uid,
      email: user.email!,
      role: role,
    );
  }

  @override
  Future<UserEntity> register(String email, String password) async {
    final user = await remoteDataSource.register(email, password);

    return UserEntity(
      uid: user.uid,
      email: user.email!,
      role: "user",
    );
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }
}
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserEntity> login(String email, String password) async {
    final user = await remoteDataSource.login(email, password);
    final userData = await remoteDataSource.getUserData(user.uid);

    return UserEntity(
      uid: user.uid,
      email: user.email!,
      role: userData['role'] ?? "user",
      name: userData['name'],
      avatarUrl: userData['avatarUrl'],
    );
  }

  @override
  Future<UserEntity> register(
    String email,
    String password, {
    String? name,
  }) async {
    final user = await remoteDataSource.register(email, password, name: name);

    return UserEntity(
      uid: user.uid,
      email: user.email!,
      role: "user",
      name: name,
    );
  }

  @override
  Future<void> updateUserProfile(
    String uid, {
    String? name,
    String? avatarUrl,
  }) async {
    await remoteDataSource.updateUserProfile(
      uid,
      name: name,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }
}

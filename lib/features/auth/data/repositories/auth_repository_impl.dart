import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/local/user_local_datasource.dart';
import '../models/user_model.dart';
import 'package:my_store/core/errors/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<UserEntity> login(String username, String password) async {
    try {
      final userModel = await remoteDataSource.login(username, password);
      await localDataSource.saveUser(userModel);
      return userModel;
    } on ServerException catch (e) {
      throw Exception('Login failed: ${e.message}');
    }
  }

  @override
  Future<UserEntity> register(
      String name, String email, String phone, String password) async {
    try {
      final userModel =
          await remoteDataSource.register(name, email, phone, password);
      await localDataSource.saveUser(userModel);
      return userModel;
    } on ServerException catch (e) {
      throw Exception('Register failed: ${e.message}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.deleteUser();
    } on ServerException catch (e) {
      throw Exception('Logout failed: ${e.message}');
    }
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final localUser = await localDataSource.getCurrentUser();

      try {
        final remoteUser = await remoteDataSource.getCurrentUser();
        if (remoteUser != null) {
          await localDataSource.saveUser(remoteUser);
          return remoteUser;
        }
      } catch (_) {
        return localUser;
      }
      return localUser;
    } on CacheException {
      return null;
    }
  }

  @override
  Future<UserEntity> updateProfile(UserEntity user) async {
    try {
      final userModel = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        phone: user.phone,
        walletBalance: user.walletBalance,
        walletId: user.walletId,
      );
      final updatedModel = await remoteDataSource.updateProfile(userModel);
      await localDataSource.saveUser(updatedModel);
      return updatedModel;
    } on ServerException catch (e) {
      throw Exception('Update failed: ${e.message}');
    }
  }
}

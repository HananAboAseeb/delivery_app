import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String username, String password);
  Future<UserEntity> register(String name, String email, String phone, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> updateProfile(UserEntity user);
}

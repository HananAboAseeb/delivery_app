import 'package:drift/drift.dart';
import 'package:my_store/core/database/database.dart';
import 'package:my_store/features/auth/data/models/user_model.dart';

abstract class UserLocalDataSource {
  Future<UserModel?> getUser();
  Future<void> saveUser(UserModel user);
  Future<void> deleteUser();
  Future<UserModel?> getCurrentUser();
}

class UserLocalDataSourceImpl implements UserLocalDataSource {
  final AppDatabase database;

  UserLocalDataSourceImpl({required this.database});

  @override
  Future<UserModel?> getUser() => getCurrentUser();

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = await database.getCurrentUser();
    if (user == null) return null;
    return UserModel(
      id: user.id,
      name: user.name ?? '',
      email: user.email,
      phone: user.phone,
      walletBalance: 0.0,
    );
  }

  @override
  Future<void> saveUser(UserModel userToCache) async {
    await database.saveUser(
      AppUsersCompanion(
        id: Value(userToCache.id),
        name: Value(userToCache.name),
        email: Value(userToCache.email),
        phone: Value(userToCache.phone),
      ),
    );
  }

  @override
  Future<void> deleteUser() async {
    await database.deleteUser();
  }
}

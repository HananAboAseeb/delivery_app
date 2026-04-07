import 'package:my_store/core/network/api_client.dart';
import 'package:my_store/features/auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile(String id);
  Future<UserModel> updateProfile(UserModel user);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final ApiClient apiClient;

  ProfileRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> getProfile(String id) async {
    // TODO: Replace with real customer profile endpoint when provided by backend team.
    // Endpoint candidate: GET /api/ECommerce/user-delivery-info/by-id/{Id}
    // Currently using local data as the Swagger does not expose a customer profile endpoint.
    await Future.delayed(const Duration(milliseconds: 300));
    return UserModel(
      id: id,
      name: 'User',
      email: '',
      phone: '',
      walletBalance: 0.0,
      walletId: '',
    );
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    // TODO: Replace with real update endpoint when provided by backend team.
    await Future.delayed(const Duration(milliseconds: 300));
    return user;
  }
}

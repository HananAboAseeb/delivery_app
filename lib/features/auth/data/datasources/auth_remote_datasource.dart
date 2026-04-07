import 'package:my_store/core/network/api_client.dart';
import 'package:my_store/core/errors/exceptions.dart';
import '../models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String username, String password);
  Future<UserModel> register(String name, String email, String phone, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<UserModel> updateProfile(UserModel user);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<UserModel> login(String username, String password) async {
    try {
      // Step 1: Get the access token
      final tokenResponse = await apiClient.dio.post(
        'https://erp.neosending.com/connect/token',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        data: {
          'grant_type': 'password',
          'client_id': 'ERP_APP',
          'username': username,
          'password': password,
        },
      );

      final token = tokenResponse.data['access_token'];
      if (token == null) {
        throw ServerException(message: 'لم يتم استلام التوكن من السيرفر');
      }

      // Step 2: Save the token
      const storage = FlutterSecureStorage();
      await storage.write(key: 'access_token', value: token);

      // Step 3: Fetch the real profile using the new token
      Map<String, dynamic>? profileData;
      try {
        final profileResponse = await apiClient.dio.get(
          '/api/account/my-profile',
          options: Options(headers: {'Authorization': 'Bearer $token'}),
        );
        profileData = profileResponse.data is Map ? profileResponse.data : null;
      } catch (e) {
        // We will not crash the login if my-profile returns 500 or 404
        profileData = null;
      }

      // Use profile data if available, otherwise just use the entered username
      final name    = profileData?['userName'] ?? profileData?['name'] ?? username;
      final email   = profileData?['email'] ?? '';
      final phone   = profileData?['phoneNumber'] ?? username;
      final id      = profileData?['id']?.toString() ?? '';

      // Step 4: Cache the profile locally so ProfileCubit can read it instantly
      await storage.write(key: 'profile_name',  value: name);
      await storage.write(key: 'profile_email', value: email);
      await storage.write(key: 'profile_phone', value: phone);

      return UserModel(
        id: id,
        name: name,
        email: email,
        phone: phone,
        walletBalance: 0.0,
        walletId: '',
      );
    } on DioException catch (e) {
      throw ServerException(message: 'Token Error: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Login failed: $e');
    }
  }

  @override
  Future<UserModel> register(String name, String email, String phone, String password) async {
    try {
      await apiClient.dio.post(
        '/api/UserManagement/cre-tech-register/register',
        data: {
          'userName': name,
          'phoneNumber': phone,
          'password': password,
        },
      );
      
      return UserModel(
        id: 'new_id',
        name: name,
        email: email,
        phone: phone,
        walletBalance: 0.0,
        walletId: '',
      );
    } on DioException catch (e) {
      throw ServerException(message: 'Register failed: ${e.response?.statusCode} - ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Register failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'access_token');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await apiClient.dio.get('/api/account/my-profile');
      final data = response.data;
      if (data == null) return null;
      
      return UserModel(
        id: data['id']?.toString() ?? '',
        name: data['userName'] ?? data['name'] ?? 'User',
        email: data['email'] ?? '',
        phone: data['phoneNumber'] ?? '',
        walletBalance: 0.0,
        walletId: '',
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<UserModel> updateProfile(UserModel user) async {
    try {
      final response = await apiClient.dio.put(
        '/api/account/my-profile',
        data: {
          'userName': user.name,
          'email': user.email,
          'phoneNumber': user.phone,
        },
      );
      
      final data = response.data;
      return UserModel(
        id: user.id,
        name: data?['userName'] ?? user.name,
        email: data?['email'] ?? user.email,
        phone: data?['phoneNumber'] ?? user.phone,
        walletBalance: user.walletBalance,
        walletId: user.walletId,
      );
    } catch (e) {
      throw ServerException(message: 'Update profile failed');
    }
  }
}

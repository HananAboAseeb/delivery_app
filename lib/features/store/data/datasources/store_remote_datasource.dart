import 'package:my_store/core/network/api_client.dart';
import 'package:my_store/core/errors/exceptions.dart';
import '../models/store_model.dart';

abstract class StoreRemoteDataSource {
  Future<List<StoreModel>> getStores();
  Future<StoreModel> getStoreById(String id);
  Future<List<StoreModel>> getStoresByRegion(String regionId);
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final ApiClient apiClient;

  StoreRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<StoreModel>> getStores() async {
    try {
      final response = await apiClient.post(
        '/api/ECommerce/stores/get-all',
        data: {
          'skipCount': 0,
          'maxResultCount': 50,
        },
      );
      final List items = response.data['items'] ?? [];
      return items.map((json) => StoreModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to fetch stores: $e');
    }
  }

  @override
  Future<StoreModel> getStoreById(String id) async {
    try {
      final response = await apiClient.get('/api/ECommerce/stores/by-id/$id');
      return StoreModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch store details: $e');
    }
  }

  @override
  Future<List<StoreModel>> getStoresByRegion(String regionId) async {
    try {
      final response = await apiClient.post(
        '/api/ECommerce/stores/get-all',
        data: {
          'filter': regionId,
          'maxResultCount': 20,
        },
      );
      final List items = response.data['items'] ?? [];
      return items.map((json) => StoreModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to search stores by region: $e');
    }
  }
}


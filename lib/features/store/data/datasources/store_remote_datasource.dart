import 'package:flutter/foundation.dart';
import 'package:my_store/core/network/api_client.dart';
import 'package:my_store/core/errors/exceptions.dart';
import '../models/store_model.dart';

abstract class StoreRemoteDataSource {
  Future<List<StoreModel>> getStores();
  Future<StoreModel> getStoreById(String id);
  Future<List<StoreModel>> getStoresByRegion(String regionId);
  Future<List<StoreGroupModel>> getStoreGroups();
  Future<List<StoreModel>> getStoresByGroup(String groupId);
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final ApiClient apiClient;

  StoreRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<StoreModel>> getStores() async {
    // Try stores-cache first (works without auth)
    try {
      debugPrint('🔄 [StoreDS] Trying /api/ECommerce/stores-cache ...');
      final response = await apiClient.get('/api/ECommerce/stores-cache');
      final List items = response.data is List ? response.data : [];
      debugPrint('✅ [StoreDS] stores-cache → ${items.length} stores');
      return items.map((json) => StoreModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('⚠️ [StoreDS] stores-cache failed: $e');
    }

    // Fallback: POST /api/ECommerce/stores/get-all
    try {
      debugPrint('🔄 [StoreDS] Trying POST /api/ECommerce/stores/get-all ...');
      final response = await apiClient.post(
        '/api/ECommerce/stores/get-all',
        data: {'maxResultCount': 100, 'skipCount': 0},
      );
      final List items = response.data['items'] ?? [];
      debugPrint('✅ [StoreDS] stores/get-all → ${items.length} stores');
      return items.map((json) {
        final data = (json as Map).containsKey('store') ? json['store'] : json;
        return StoreModel.fromJson(data as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('❌ [StoreDS] All store endpoints failed: $e');
      throw ServerException(message: 'Failed to fetch stores: $e');
    }
  }

  @override
  Future<StoreModel> getStoreById(String id) async {
    try {
      final response = await apiClient.get('/api/ECommerce/stores/by-id/$id');
      final data = response.data;
      final storeData = data is Map && data.containsKey('store') ? data['store'] : data;
      return StoreModel.fromJson(storeData as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch store details: $e');
    }
  }

  @override
  Future<List<StoreModel>> getStoresByRegion(String regionId) async {
    try {
      final response = await apiClient.post(
        '/api/ECommerce/stores/get-all',
        data: {'filter': regionId, 'maxResultCount': 50},
      );
      final List items = response.data['items'] ?? [];
      return items.map((json) {
        final data = (json as Map).containsKey('store') ? json['store'] : json;
        return StoreModel.fromJson(data as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to search stores by region: $e');
    }
  }

  @override
  Future<List<StoreGroupModel>> getStoreGroups() async {
    try {
      debugPrint('🔄 [StoreDS] Trying /api/ECommerce/store-groups-cache ...');
      final response = await apiClient.get('/api/ECommerce/store-groups-cache');
      final List items = response.data is List ? response.data : [];
      debugPrint('✅ [StoreDS] store-groups-cache → ${items.length} groups');
      for (final item in items) {
        debugPrint('   → Group: ${item['name']} (id: ${item['id']})');
      }
      return items.map((json) => StoreGroupModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('❌ [StoreDS] store-groups-cache failed: $e');
      throw ServerException(message: 'Failed to fetch store groups: $e');
    }
  }

  @override
  Future<List<StoreModel>> getStoresByGroup(String groupId) async {
    try {
      debugPrint('🔄 [StoreDS] Trying stores/get-all for group: $groupId ...');
      final response = await apiClient.post(
        '/api/ECommerce/stores/get-all',
        data: {
          'maxResultCount': 100,
          'skipCount': 0,
          'specificFilters': [
            {'key': 'StoreGroupId', 'condition': '==', 'value': groupId}
          ],
        },
      );
      final List items = response.data['items'] ?? [];
      debugPrint('✅ [StoreDS] stores by group → ${items.length} stores');
      return items.map((json) {
        final data = (json as Map).containsKey('store') ? json['store'] : json;
        return StoreModel.fromJson(data as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('❌ [StoreDS] getStoresByGroup failed: $e');
      throw ServerException(message: 'Failed to fetch stores by group: $e');
    }
  }
}

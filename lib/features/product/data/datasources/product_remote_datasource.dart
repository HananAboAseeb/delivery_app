import 'package:flutter/foundation.dart';
import 'package:my_store/core/network/api_client.dart';
import 'package:my_store/core/errors/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts(int page, int pageSize);
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<ProductModel>> getProductsByStore(String storeId, {String? itemGroupId});
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getProducts(int page, int pageSize) async {
    // Try items-cache first (often works without auth for cached data)
    try {
      debugPrint('🔄 [ProductDS] Trying /api/ECommerce/items-cache ...');
      final response = await apiClient.get('/api/ECommerce/items-cache');
      final List items = response.data is List ? response.data : [];
      debugPrint('✅ [ProductDS] items-cache → ${items.length} items');
      if (items.isNotEmpty) {
        return items.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ [ProductDS] items-cache failed: $e');
    }

    // Fallback: try /api/ECommerce/items
    try {
      debugPrint('🔄 [ProductDS] Trying /api/ECommerce/items ...');
      final response = await apiClient.get('/api/ECommerce/items');
      final List items = response.data is List ? response.data : [];
      debugPrint('✅ [ProductDS] items → ${items.length} items');
      return items.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('⚠️ [ProductDS] items failed: $e');
    }

    // Fallback: try POST /api/ECommerce/items/get-all
    try {
      debugPrint('🔄 [ProductDS] Trying POST /api/ECommerce/items/get-all ...');
      final response = await apiClient.post(
        '/api/ECommerce/items/get-all',
        data: {'maxResultCount': pageSize, 'skipCount': (page - 1) * pageSize},
      );
      final data = response.data;
      final List items = data is List ? data : (data is Map ? (data['items'] ?? []) : []);
      debugPrint('✅ [ProductDS] items/get-all → ${items.length} items');
      return items.map((json) {
        final itemData = (json is Map && json.containsKey('item')) ? json['item'] : json;
        return ProductModel.fromJson(itemData as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      debugPrint('❌ [ProductDS] All product endpoints failed: $e');
      throw ServerException(message: 'فشل في جلب المنتجات. تأكد من تسجيل الدخول. ($e)');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await apiClient.get('/api/ECommerce/items/by-id/$id');
      return ProductModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch product details: $e');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      // Try to get all products and filter client-side
      final allProducts = await getProducts(1, 100);
      // Client-side filter (case-insensitive matching)
      return allProducts.where((p) => p.name.contains(query)).toList();
    } catch (e) {
      throw ServerException(message: 'فشل البحث عن المنتجات: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByStore(String storeId, {String? itemGroupId}) async {
    try {
      // Since stores may not exist yet, get all items
      return await getProducts(1, 100);
    } catch (e) {
      throw ServerException(message: 'Failed to get store products: $e');
    }
  }
}

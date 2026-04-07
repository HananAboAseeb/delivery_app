import 'package:my_store/core/network/api_client.dart';
import 'package:my_store/core/errors/exceptions.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts(int page, int pageSize);
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<ProductModel>> getProductsByStore(String storeId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final ApiClient apiClient;

  ProductRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<ProductModel>> getProducts(int page, int pageSize) async {
    try {
      final response = await apiClient.post(
        '/api/ECommerce/items/get-all',
        data: {
          'skipCount': (page - 1) * pageSize,
          'maxResultCount': pageSize,
        },
      );
      final List items = response.data['items'] ?? [];
      return items.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get products: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await apiClient.get('/api/ECommerce/items/by-id/$id');
      return ProductModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: 'Failed to fetch product details: $e');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      final response = await apiClient.post(
        '/api/ECommerce/items/get-all',
        data: {
          'filter': query,
          'maxResultCount': 20,
        },
      );
      final List items = response.data['items'] ?? [];
      return items.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to search products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByStore(String storeId) async {
    try {
      final response = await apiClient.post(
        '/api/ECommerce/items/get-all',
        data: {
          'storeId': storeId,
          'maxResultCount': 50,
        },
      );
      final List items = response.data['items'] ?? [];
      return items.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get store products: $e');
    }
  }
}

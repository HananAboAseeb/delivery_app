import 'package:my_store/core/network/api_client.dart';
import 'package:my_store/core/errors/exceptions.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder(OrderModel order);
  Future<List<OrderModel>> getOrders({String? status, DateTime? date});
  Future<OrderModel> getOrderById(String id);
  Future<void> cancelOrder(String id);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final ApiClient apiClient;

  OrderRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      final response = await apiClient.post(
        '/api/ECommerce/checkout/checkout',
        data: order.toJson(),
      );
      return OrderModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: 'Failed to create order: $e');
    }
  }

  @override
  Future<List<OrderModel>> getOrders({String? status, DateTime? date}) async {
    try {
      final response = await apiClient.get(
        '/api/ECommerce/merchant-orders/my-orders',
        queryParameters: {
          if (status != null) 'status': status,
        },
      );
      final List items = response.data['items'] ?? response.data ?? [];
      return items.map((json) => OrderModel.fromJson(json)).toList();
    } catch (e) {
      throw ServerException(message: 'Failed to get orders: $e');
    }
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    try {
      final response = await apiClient.get(
        '/api/ECommerce/checkout/master/$id',
      );
      return OrderModel.fromJson(response.data);
    } catch (e) {
      throw ServerException(message: 'Failed to get order by id: $e');
    }
  }

  @override
  Future<void> cancelOrder(String id) async {
    try {
      await apiClient.post('/api/ECommerce/checkout/cancel-order/$id');
    } catch (e) {
      throw ServerException(message: 'Failed to cancel order: $e');
    }
  }
}

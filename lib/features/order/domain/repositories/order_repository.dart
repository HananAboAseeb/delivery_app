import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<OrderEntity> createOrder(OrderEntity order);
  Future<List<OrderEntity>> getOrders({String? status, DateTime? date});
  Future<OrderEntity> getOrderById(String id);
  Future<void> cancelOrder(String id);
}

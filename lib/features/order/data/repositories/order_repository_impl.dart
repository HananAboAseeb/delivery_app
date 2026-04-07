import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_datasource.dart';
import '../datasources/local/orders_local_datasource.dart';
import '../models/order_model.dart';
import 'package:my_store/core/errors/exceptions.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final OrdersLocalDataSource localDataSource;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<OrderEntity> createOrder(OrderEntity order) async {
    try {
      final model = await remoteDataSource.createOrder(OrderModel(
        id: order.id,
        masterOrderNumber: order.masterOrderNumber,
        totalPrice: order.totalPrice,
        status: order.status,
        creationTime: order.creationTime,
        currency: order.currency,
      ));
      return model;
    } on ServerException catch (e) {
      throw Exception('Checkout failed: ${e.message}');
    }
  }

  @override
  Future<List<OrderEntity>> getOrders({String? status, DateTime? date}) async {
    try {
      final remoteOrders = await remoteDataSource.getOrders(status: status, date: date);
      // Cache each order
      for (final order in remoteOrders) {
        await localDataSource.cacheOrder(order);
      }
      return remoteOrders;
    } catch (_) {
      // Fallback to local cache
      try {
        return await localDataSource.getOrders();
      } catch (cacheError) {
        throw Exception('Failed to fetch orders from remote and local cache');
      }
    }
  }

  @override
  Future<OrderEntity> getOrderById(String id) async {
    try {
      return await remoteDataSource.getOrderById(id);
    } on ServerException catch (e) {
      throw Exception('Failed fetching order details: ${e.message}');
    }
  }

  @override
  Future<void> cancelOrder(String id) async {
    try {
      await remoteDataSource.cancelOrder(id);
    } on ServerException catch (e) {
      throw Exception('Cancel failed: ${e.message}');
    }
  }
}

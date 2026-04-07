import 'package:drift/drift.dart';
import 'package:my_store/core/database/database.dart';
import 'package:my_store/features/order/data/models/order_model.dart';

abstract class OrdersLocalDataSource {
  Future<List<OrderModel>> getOrders();
  Future<void> cacheOrder(OrderModel order);
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  final AppDatabase database;

  OrdersLocalDataSourceImpl({required this.database});

  @override
  Future<List<OrderModel>> getOrders() async {
    final orders = await database.getAllOrders();
    return orders.map((e) => OrderModel(
      id: e.id,
      masterOrderNumber: e.orderNumber.toString(),
      totalPrice: e.totalAmount,
      status: e.status,
      creationTime: e.orderDate,
      currency: e.currency,
    )).toList();
  }

  @override
  Future<void> cacheOrder(OrderModel order) async {
    await database.cacheOrder(
      OrderHeadersCompanion(
        id: Value(order.id),
        orderNumber: Value(int.tryParse(order.masterOrderNumber) ?? 0),
        totalAmount: Value(order.totalPrice),
        status: Value(order.status),
        orderDate: Value(order.creationTime),
        currency: Value(order.currency),
      ),
    );
  }
}

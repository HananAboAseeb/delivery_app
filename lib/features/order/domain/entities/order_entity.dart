import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productName,
        quantity,
        unitPrice,
      ];
}

class OrderEntity extends Equatable {
  final String id;
  final String masterOrderNumber;
  final double totalPrice;
  final String status;
  final DateTime creationTime;
  final String currency;

  const OrderEntity({
    required this.id,
    required this.masterOrderNumber,
    required this.totalPrice,
    required this.status,
    required this.creationTime,
    required this.currency,
  });

  @override
  List<Object?> get props => [
        id,
        masterOrderNumber,
        totalPrice,
        status,
        creationTime,
        currency,
      ];
}

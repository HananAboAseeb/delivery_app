import '../../domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] ?? json['rowId'] ?? '',
      orderId: json['orderId'] ?? '',
      productId: json['productId'] ?? json['itemId'] ?? '',
      productName: json['productName'] ?? json['itemName'] ?? '',
      quantity: json['quantity'] ?? json['qty'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
    };
  }
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.masterOrderNumber,
    required super.totalPrice,
    required super.status,
    required super.creationTime,
    required super.currency,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      masterOrderNumber: json['masterOrderNumber'] ?? json['orderNo'] ?? '',
      totalPrice: (json['totalPrice'] ??
              json['totalAmount'] ??
              json['grandTotal'] ??
              0.0)
          .toDouble(),
      status: json['status']?.toString() ?? 'Pending',
      creationTime: json['creationTime'] != null
          ? DateTime.tryParse(json['creationTime']) ?? DateTime.now()
          : DateTime.now(),
      currency: json['currency'] ?? json['currencyName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'masterOrderNumber': masterOrderNumber,
      'totalPrice': totalPrice,
      'status': status,
      'creationTime': creationTime.toIso8601String(),
      'currency': currency,
    };
  }

  OrderEntity toEntity() => this;
}

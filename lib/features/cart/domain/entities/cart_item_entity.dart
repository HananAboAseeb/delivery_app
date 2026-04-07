import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final String? size;
  final String? color;
  final String storeId;
  final String storeName;

  const CartItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.size,
    this.color,
    required this.storeId,
    required this.storeName,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        quantity,
        unitPrice,
        totalPrice,
        size,
        color,
        storeId,
        storeName,
      ];
}

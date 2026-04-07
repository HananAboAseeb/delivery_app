import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.quantity,
    required super.unitPrice,
    required super.totalPrice,
    super.size,
    super.color,
    required super.storeId,
    required super.storeName,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0.0).toDouble(),
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      size: json['size'],
      color: json['color'],
      storeId: json['storeId'] ?? '',
      storeName: json['storeName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'size': size,
      'color': color,
      'storeId': storeId,
      'storeName': storeName,
    };
  }

  CartItemModel copyWith({
    String? id,
    String? productId,
    String? productName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    String? size,
    String? color,
    String? storeId,
    String? storeName,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      size: size ?? this.size,
      color: color ?? this.color,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
    );
  }

  CartItemEntity toEntity() => this;
}

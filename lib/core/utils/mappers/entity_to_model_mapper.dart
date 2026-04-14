import 'package:my_store/features/auth/domain/entities/user_entity.dart';
import 'package:my_store/features/auth/data/models/user_model.dart';
import 'package:my_store/features/product/domain/entities/product_entity.dart';
import 'package:my_store/features/product/data/models/product_model.dart';
import 'package:my_store/features/cart/domain/entities/cart_item_entity.dart';
import 'package:my_store/features/cart/data/models/cart_item_model.dart';
import 'package:my_store/features/order/domain/entities/order_entity.dart';
import 'package:my_store/features/order/data/models/order_model.dart';
import 'package:my_store/features/store/domain/entities/store_entity.dart';
import 'package:my_store/features/store/data/models/store_model.dart';

extension UserEntityX on UserEntity {
  UserModel toModel() => UserModel(
        id: id,
        name: name,
        email: email,
        phone: phone,
        walletBalance: walletBalance,
        walletId: walletId,
      );
}

extension ProductEntityX on ProductEntity {
  ProductModel toModel() => ProductModel(
        id: id,
        theNumber: theNumber,
        name: name,
        foreignName: foreignName,
        unitId: unitId,
        unitName: unitName,
        currencyId: currencyId,
        currencyName: currencyName,
        unitPrice: unitPrice,
        imageUrl: imageUrl,
        isActive: isActive,
      );
}

extension CartItemEntityX on CartItemEntity {
  CartItemModel toModel() => CartItemModel(
        id: id,
        productId: productId,
        productName: productName,
        quantity: quantity,
        unitPrice: unitPrice,
        totalPrice: totalPrice,
        size: size,
        color: color,
        storeId: storeId,
        storeName: storeName,
      );
}

extension OrderEntityX on OrderEntity {
  OrderModel toModel() => OrderModel(
        id: id,
        masterOrderNumber: masterOrderNumber,
        totalPrice: totalPrice,
        status: status,
        creationTime: creationTime,
        currency: currency,
      );
}

extension StoreEntityX on StoreEntity {
  StoreModel toModel() => StoreModel(
        id: id,
        theNumber: theNumber,
        name: name,
        foreignName: foreignName,
        isActive: isActive,
        imageUrl: imageUrl,
        latitude: latitude,
        longitude: longitude,
      );
}

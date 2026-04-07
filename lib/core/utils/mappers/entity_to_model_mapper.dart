import '../../../features/auth/domain/entities/user_entity.dart';
import '../../../features/auth/data/models/user_model.dart';
import '../../../features/product/domain/entities/product_entity.dart';
import '../../../features/product/data/models/product_model.dart';
import '../../../features/cart/domain/entities/cart_item_entity.dart';
import '../../../features/cart/data/models/cart_item_model.dart';
import '../../../features/order/domain/entities/order_entity.dart';
import '../../../features/order/data/models/order_model.dart';
import '../../../features/store/domain/entities/store_entity.dart';
import '../../../features/store/data/models/store_model.dart';

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

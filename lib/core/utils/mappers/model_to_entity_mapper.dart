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

extension UserModelX on UserModel {
  UserEntity toEntity() => this; // Polymorphic resolution
}

extension ProductModelX on ProductModel {
  ProductEntity toEntity() => this;
}

extension CartItemModelX on CartItemModel {
  CartItemEntity toEntity() => this;
}

extension OrderModelX on OrderModel {
  OrderEntity toEntity() => this;
}

extension StoreModelX on StoreModel {
  StoreEntity toEntity() => this;
}

extension StoreGroupModelX on StoreGroupModel {
  StoreGroupEntity toEntity() => this;
}

extension StoreItemGroupModelX on StoreItemGroupModel {
  StoreItemGroupEntity toEntity() => this;
}

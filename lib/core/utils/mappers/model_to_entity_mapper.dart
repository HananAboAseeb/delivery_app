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

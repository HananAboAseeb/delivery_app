import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/local/cart_local_datasource.dart';
import 'package:my_store/core/utils/mappers/entity_to_model_mapper.dart';

class CartRepositoryImpl implements CartRepository {
  final CartLocalDataSource localDataSource;
  // If cart is synched with an API, inject CartRemoteDataSource here.
  // For Swagger context provided, we mostly rely on local cart until checkout.

  CartRepositoryImpl({required this.localDataSource});

  @override
  Future<List<CartItemEntity>> getCart() async {
    final models = await localDataSource.getCartItems();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> addToCart(CartItemEntity item) async {
    await localDataSource.addToCart(item.toModel());
  }

  @override
  Future<void> removeFromCart(String itemId) async {
    await localDataSource.removeFromCart(itemId);
  }

  @override
  Future<void> updateQuantity(String itemId, int quantity) async {
    await localDataSource.updateCartQuantity(itemId, quantity);
  }

  @override
  Future<void> clearCart() async {
    await localDataSource.clearCart();
  }
}

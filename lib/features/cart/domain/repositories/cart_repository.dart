import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<List<CartItemEntity>> getCart();
  Future<void> addToCart(CartItemEntity item);
  Future<void> removeFromCart(String itemId);
  Future<void> updateQuantity(String itemId, int quantity);
  Future<void> clearCart();
}

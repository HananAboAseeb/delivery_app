import 'package:drift/drift.dart';
import 'package:my_store/core/database/database.dart';
import 'package:my_store/features/cart/data/models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> addToCart(CartItemModel item);
  Future<void> removeFromCart(String id);
  Future<void> updateCartQuantity(String id, int quantity);
  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  final AppDatabase database;

  CartLocalDataSourceImpl({required this.database});

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final items = await database.getCartItems();
    return items.map((e) => CartItemModel(
      id: e.id.toString(), // The table uses IntColumn but the model uses String
      productId: e.productId,
      productName: e.productName,
      quantity: e.quantity.toInt(),
      unitPrice: e.unitPrice,
      totalPrice: e.totalPrice,
      size: e.size,
      color: e.color,
      storeId: e.storeId,
      storeName: e.storeName,
    )).toList();
  }

  @override
  Future<void> addToCart(CartItemModel item) async {
    // Check if the product already exists in the cart by productId
    final existingItems = await database.getCartItems();
    final existing = existingItems.where((e) => e.productId == item.productId).firstOrNull;

    if (existing != null) {
      // Update quantity and total price
      final newQuantity = existing.quantity + item.quantity;
      final newTotal = newQuantity * existing.unitPrice;
      
      await database.addOrUpdateCartItem(
        CartItemsCompanion(
          id: Value(existing.id),
          productId: Value(existing.productId),
          productName: Value(existing.productName),
          quantity: Value(newQuantity),
          unitPrice: Value(existing.unitPrice),
          totalPrice: Value(newTotal),
          size: Value(existing.size),
          color: Value(existing.color),
          storeId: Value(existing.storeId),
          storeName: Value(existing.storeName),
        ),
      );
    } else {
      // Insert new
      await database.addOrUpdateCartItem(
        CartItemsCompanion(
          productId: Value(item.productId),
          productName: Value(item.productName),
          quantity: Value(item.quantity.toDouble()),
          unitPrice: Value(item.unitPrice),
          totalPrice: Value(item.totalPrice),
          size: Value(item.size),
          color: Value(item.color),
          storeId: Value(item.storeId),
          storeName: Value(item.storeName),
        ),
      );
    }
  }

  @override
  Future<void> removeFromCart(String id) async {
    await database.removeCartItem(int.parse(id));
  }

  @override
  Future<void> updateCartQuantity(String id, int quantity) async {
    final intId = int.parse(id);
    final existingItems = await database.getCartItems();
    final existing = existingItems.where((e) => e.id == intId).firstOrNull;

    if (existing != null) {
      final newTotal = quantity * existing.unitPrice;
      await database.addOrUpdateCartItem(
        CartItemsCompanion(
          id: Value(existing.id),
          productId: Value(existing.productId),
          productName: Value(existing.productName),
          quantity: Value(quantity.toDouble()),
          unitPrice: Value(existing.unitPrice),
          totalPrice: Value(newTotal),
          size: Value(existing.size),
          color: Value(existing.color),
          storeId: Value(existing.storeId),
          storeName: Value(existing.storeName),
        ),
      );
    }
  }

  @override
  Future<void> clearCart() async {
    await database.clearCart();
  }
}

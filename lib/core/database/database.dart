import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:my_store/core/database/tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [CartItems, OrderHeaders, AppUsers])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Cart Methods
  Future<List<CartItem>> getCartItems() => select(cartItems).get();
  Stream<List<CartItem>> watchCartItems() => select(cartItems).watch();
  Future<int> addOrUpdateCartItem(CartItemsCompanion item) =>
      into(cartItems).insertOnConflictUpdate(item);
  Future<int> removeCartItem(int id) =>
      (delete(cartItems)..where((t) => t.id.equals(id))).go();
  Future<int> clearCart() => delete(cartItems).go();

  // Order Methods
  Future<List<OrderHeader>> getAllOrders() => select(orderHeaders).get();
  Future<int> cacheOrder(OrderHeadersCompanion order) =>
      into(orderHeaders).insert(order);

  // User Methods
  Future<AppUser?> getCurrentUser() async {
    final users = await select(appUsers).get();
    return users.isNotEmpty ? users.first : null;
  }

  Future<int> saveUser(AppUsersCompanion user) =>
      into(appUsers).insertOnConflictUpdate(user);
  Future<int> deleteUser() => delete(appUsers).go();
}

QueryExecutor _openConnection() {
  return driftDatabase(name: 'my_store.db');
}

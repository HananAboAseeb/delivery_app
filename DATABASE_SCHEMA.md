# Drift Database Schema

Based on the required offline data and the extracted schemas in `swagger.json`.

## Tables

### 1. `Products` (Local cache of `ItemsForViewDto` & `ItemCardCache`)
```dart
class Products extends Table {
  TextColumn get id => text()(); // Item ID
  TextColumn get itemNo => text()();
  TextColumn get name => text()();
  RealColumn get unitPrice => real()();
  RealColumn get offerPrice => real().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get unitId => text()();
  TextColumn get unitName => text()();
  TextColumn get categoryId => text().nullable()(); // itemGroupId
  TextColumn get storeId => text().nullable()();
  
  @override
  Set<Column> get primaryKey => {id};
}
```

### 2. `CartItems` (Local Cart logic integrating with `MyBasketInfo`)
```dart
class CartItems extends Table {
  TextColumn get id => text()(); // local generated ID
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get productName => text()();
  TextColumn get unitId => text()();
  TextColumn get unitName => text()();
  RealColumn get unitPrice => real()();
  IntColumn get quantity => integer().withDefault(const Constant(1))();
  RealColumn get totalPrice => real()();
  TextColumn get storeId => text()(); // For multi-vendor cart

  @override
  Set<Column> get primaryKey => {id};
}
```

### 3. `OrderHeaders` (From `MyOrderHead` & `DeliveryOrderDto`)
```dart
class OrderHeaders extends Table {
  TextColumn get id => text()();
  TextColumn get orderNo => text()();
  TextColumn get status => text()(); // pending, processing, shipped, etc.
  RealColumn get totalAmount => real()();
  RealColumn get deliveryAmount => real().nullable()();
  TextColumn get cityName => text().nullable()();
  TextColumn get regionName => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get orderDate => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 4. `OrderLines` (From `OrderItem` & `MerchantOrderLines`)
```dart
class OrderLines extends Table {
  TextColumn get rowId => text()();
  TextColumn get orderId => text().references(OrderHeaders, #id)();
  TextColumn get itemId => text()();
  TextColumn get itemName => text()();
  IntColumn get quantity => integer()();
  RealColumn get unitPrice => real()();
  RealColumn get totalPrice => real()();
  
  @override
  Set<Column> get primaryKey => {rowId};
}
```

### 5. `Users` (From `CurrentUserDto`)
```dart
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get userName => text()();
  TextColumn get name => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phoneNumber => text().nullable()();
  TextColumn get roles => text().nullable()(); // Comma separated roles
  
  @override
  Set<Column> get primaryKey => {id};
}
```

import 'package:drift/drift.dart';

class CartItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  RealColumn get quantity => real()();
  RealColumn get unitPrice => real()();
  RealColumn get totalPrice => real()();
  TextColumn get size => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get storeId => text()();
  TextColumn get storeName => text()();
}

class OrderHeaders extends Table {
  TextColumn get id => text()();
  IntColumn get orderNumber => integer()();
  RealColumn get totalAmount => real()();
  TextColumn get status => text()();
  DateTimeColumn get orderDate => dateTime()();
  TextColumn get currency => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class AppUsers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().nullable()();
  TextColumn get email => text()();
  TextColumn get phone => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

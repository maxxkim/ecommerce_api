import 'products.dart';
import 'package:drift/drift.dart';
import 'orders.dart';

class OrderItems extends Table {
  TextColumn get id => text()
      .clientDefault(() => DateTime.now().millisecondsSinceEpoch.toString())();
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get quantity => integer()();
  RealColumn get price => real()(); // Unit price at the time of purchase
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  TextColumn get attributes => text()
      .map(const JsonMapConverter<String, dynamic>())
      .nullable()(); // Selected variants

  @override
  Set<Column> get primaryKey => {id};
}

// Import the JsonMapConverter

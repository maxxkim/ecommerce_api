import 'package:drift/drift.dart';
import 'orders.dart';
import 'products.dart';

class Payments extends Table {
  TextColumn get id => text()
      .clientDefault(() => DateTime.now().millisecondsSinceEpoch.toString())();
  TextColumn get orderId => text().references(Orders, #id)();
  TextColumn get paymentMethod => text()(); // credit_card, paypal, etc.
  TextColumn get paymentStatus =>
      text()(); // pending, completed, failed, refunded
  RealColumn get amount => real()();
  TextColumn get transactionId =>
      text().nullable()(); // External payment provider transaction ID
  TextColumn get paymentDetails => text()
      .map(const JsonMapConverter<String, dynamic>())
      .nullable()(); // Payment gateway response
  DateTimeColumn get paymentDate =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {id};
}

// Import the JsonMapConverter

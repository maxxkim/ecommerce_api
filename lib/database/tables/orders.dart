import 'package:drift/drift.dart';
import 'users.dart';
import 'addresses.dart';

class Orders extends Table {
  TextColumn get id => text()
      .clientDefault(() => DateTime.now().millisecondsSinceEpoch.toString())();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get shippingAddressId => text().references(Addresses, #id)();
  TextColumn get billingAddressId => text().references(Addresses, #id)();
  TextColumn get status => text().withDefault(const Constant(
      'pending'))(); // pending, processing, shipped, delivered, cancelled
  RealColumn get subtotal => real()();
  RealColumn get tax => real()();
  RealColumn get shippingCost => real()();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  RealColumn get total => real()();
  TextColumn get paymentStatus => text().withDefault(
      const Constant('pending'))(); // pending, paid, failed, refunded
  TextColumn get shippingMethod => text().nullable()();
  TextColumn get trackingNumber => text().nullable()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get cancelReason => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

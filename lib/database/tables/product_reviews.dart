import 'package:drift/drift.dart';
import 'users.dart';
import 'products.dart';

class ProductReviews extends Table {
  TextColumn get id => text()
      .clientDefault(() => DateTime.now().millisecondsSinceEpoch.toString())();
  TextColumn get productId => text().references(Products, #id)();
  TextColumn get userId => text().references(Users, #id)();
  IntColumn get rating => integer()(); // 1-5 stars
  TextColumn get title => text().nullable()();
  TextColumn get comment => text()();
  BoolColumn get isVerifiedPurchase =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();
  BoolColumn get isApproved => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

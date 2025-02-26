import 'package:drift/drift.dart';
import 'users.dart';

class Addresses extends Table {
  TextColumn get id => text()
      .clientDefault(() => DateTime.now().millisecondsSinceEpoch.toString())();
  TextColumn get userId => text().references(Users, #id)();
  TextColumn get fullName => text()();
  TextColumn get addressLine1 => text()();
  TextColumn get addressLine2 => text().nullable()();
  TextColumn get city => text()();
  TextColumn get state => text()();
  TextColumn get postalCode => text()();
  TextColumn get country => text()();
  TextColumn get phoneNumber => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  TextColumn get addressType => text()
      .withDefault(const Constant('shipping'))(); // shipping, billing, both
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();

  @override
  Set<Column> get primaryKey => {id};
}

import 'package:drift/drift.dart';

class Users extends Table {
  TextColumn get id => text()
      .clientDefault(() => DateTime.now().millisecondsSinceEpoch.toString())();
  TextColumn get email => text().unique()();
  TextColumn get passwordHash => text()();
  TextColumn get firstName => text()();
  TextColumn get lastName => text()();
  TextColumn get role => text()
      .withDefault(const Constant('customer'))(); // admin, customer, support
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();
  BoolColumn get isVerified => boolean().withDefault(const Constant(false))();
  TextColumn get verificationToken => text().nullable()();
  DateTimeColumn get lastLogin => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get resetPasswordToken => text().nullable()();
  DateTimeColumn get resetPasswordExpires => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

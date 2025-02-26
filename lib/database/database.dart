import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ecommerce_api/database/tables/addresses.dart';
import 'package:ecommerce_api/database/tables/categories.dart';
import 'package:ecommerce_api/database/tables/order_items.dart';
import 'package:ecommerce_api/database/tables/orders.dart';
import 'package:ecommerce_api/database/tables/payments.dart';
import 'package:ecommerce_api/database/tables/product_reviews.dart';
import 'package:ecommerce_api/database/tables/products.dart';
import 'package:ecommerce_api/database/tables/users.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    Categories,
    Products,
    Orders,
    OrderItems,
    Addresses,
    Payments,
    ProductReviews,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
    );
  }

  // Helper method to create or update tables for testing
  Future<void> createTables() async {
    await customStatement('PRAGMA foreign_keys = OFF');

    // Drop tables if they exist
    await customStatement('DROP TABLE IF EXISTS users');

    // Create tables
    await customStatement('''
CREATE TABLE IF NOT EXISTS users (
  id TEXT NOT NULL PRIMARY KEY, 
  email TEXT NOT NULL UNIQUE, 
  password_hash TEXT NOT NULL, 
  first_name TEXT NOT NULL, 
  last_name TEXT NOT NULL, 
  role TEXT NOT NULL DEFAULT 'customer', 
  created_at TEXT NOT NULL, 
  updated_at TEXT NOT NULL, 
  is_verified INTEGER NOT NULL DEFAULT 0, 
  verification_token TEXT, 
  last_login TEXT, 
  is_active INTEGER NOT NULL DEFAULT 1, 
  reset_password_token TEXT, 
  reset_password_expires TEXT
)
    ''');

    await customStatement('PRAGMA foreign_keys = ON');
  }

  // Create admin user for testing
  Future<void> createAdminUser() async {
    final adminExists = await (select(users)
          ..where((u) => u.email.equals('admin@example.com')))
        .getSingleOrNull();

    if (adminExists == null) {
      await into(users).insert(
        UsersCompanion.insert(
          id: Value('1'),
          email: 'admin@example.com',
          passwordHash:
              r'$2a$10$I3aBg.P1ZTS0LaHEVI.Pq.jg5K6J2v.hZmEFZg4FKSqL7GXnQVN0e', // password = admin123
          firstName: 'Admin',
          lastName: 'User',
          role: Value('admin'),
          createdAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
          isVerified: Value(true),
        ),
      );
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    // For server-side applications without Flutter, store the database in the current directory
    final dbFolder = Directory.current;
    final file = File(p.join(dbFolder.path, 'db', 'ecommerce.sqlite'));

    // Make sure the folder exists
    final dbDir = Directory(p.join(dbFolder.path, 'db'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    return NativeDatabase(file);
  });
}

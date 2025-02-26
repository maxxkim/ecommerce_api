import 'package:drift/drift.dart';
import 'categories.dart';
import 'dart:convert';

class Products extends Table {
  TextColumn get id => text()
      .clientDefault(() => DateTime.now().millisecondsSinceEpoch.toString())();
  TextColumn get name => text()();
  TextColumn get description => text()();
  TextColumn get slug => text().unique()();
  RealColumn get price => real()();
  RealColumn get discountPrice => real().nullable()();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
  TextColumn get categoryId => text().references(Categories, #id)();
  TextColumn get imageUrls =>
      text().map(const JsonListConverter<String>())(); // Stored as JSON array
  TextColumn get attributes => text()
      .map(const JsonMapConverter<String, dynamic>())
      .nullable()(); // For color, size, etc.
  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();
  DateTimeColumn get updatedAt =>
      dateTime().clientDefault(() => DateTime.now())();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get viewCount => integer().withDefault(const Constant(0))();
  IntColumn get salesCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// Type converters for JSON data
class JsonListConverter<T> extends TypeConverter<List<T>, String> {
  const JsonListConverter();

  @override
  List<T> fromSql(String fromDb) {
    final decoded = json.decode(fromDb) as List;
    return decoded.cast<T>();
  }

  @override
  String toSql(List<T> value) {
    return json.encode(value);
  }
}

class JsonMapConverter<K, V> extends TypeConverter<Map<K, V>, String> {
  const JsonMapConverter();

  @override
  Map<K, V> fromSql(String fromDb) {
    final decoded = json.decode(fromDb) as Map;
    return decoded.cast<K, V>();
  }

  @override
  String toSql(Map<K, V> value) {
    return json.encode(value);
  }
}

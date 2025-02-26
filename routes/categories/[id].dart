import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:ecommerce_api/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context, String id) async {
  final db = context.read<AppDatabase>();

  // Check if category exists
  final category = await (db.select(db.categories)
        ..where((c) => c.id.equals(id)))
      .getSingleOrNull();

  if (category == null) {
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {
        'success': false,
        'message': 'Category not found',
      },
    );
  }

  switch (context.request.method) {
    case HttpMethod.get:
      return Response.json(
        body: {
          'success': true,
          'data': category,
        },
      );

    case HttpMethod.put:
    case HttpMethod.patch:
      return _handleUpdateCategory(context, db, id, category);

    case HttpMethod.delete:
      return _handleDeleteCategory(context, db, id);

    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _handleUpdateCategory(
  RequestContext context,
  AppDatabase db,
  String id,
  dynamic existingCategory,
) async {
  try {
    final json = await context.request.json() as Map<String, dynamic>;

    // Prepare values for companion
    Value<String>? nameValue;
    Value<String>? descriptionValue;
    Value<String?>? parentIdValue;
    Value<String>? slugValue;
    Value<bool>? isActiveValue;

    // Apply updates only for fields that are provided
    if (json.containsKey('name')) {
      nameValue = Value(json['name'] as String);
    }

    if (json.containsKey('description')) {
      descriptionValue = Value(json['description'] as String? ?? '');
    }

    if (json.containsKey('parentId')) {
      parentIdValue = Value(json['parentId'] as String?);
    }

    if (json.containsKey('slug')) {
      final slug = json['slug'] as String;

      // Ensure slug is unique (unless it's unchanged)
      if (slug != existingCategory.slug) {
        final existingWithSlug = await (db.select(db.categories)
              ..where((c) => c.slug.equals(slug)))
            .getSingleOrNull();

        if (existingWithSlug != null) {
          return Response.json(
            statusCode: HttpStatus.badRequest,
            body: {
              'success': false,
              'message': 'A category with this slug already exists',
            },
          );
        }
      }

      slugValue = Value(slug);
    }

    if (json.containsKey('isActive')) {
      isActiveValue = Value(json['isActive'] as bool);
    }

    // Build companion with provided fields
    final updatedCategory = CategoriesCompanion(
      id: Value(id),
      name: nameValue ?? const Value.absent(),
      description: descriptionValue ?? const Value.absent(),
      parentId: parentIdValue ?? const Value.absent(),
      slug: slugValue ?? const Value.absent(),
      isActive: isActiveValue ?? const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    // Update the category
    await db.update(db.categories).replace(updatedCategory);

    // Fetch the updated category
    final updated = await (db.select(db.categories)
          ..where((c) => c.id.equals(id)))
        .getSingle();

    return Response.json(
      body: {
        'success': true,
        'message': 'Category updated successfully',
        'data': updated,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'success': false,
        'message': 'Failed to update category',
        'error': e.toString(),
      },
    );
  }
}

Future<Response> _handleDeleteCategory(
  RequestContext context,
  AppDatabase db,
  String id,
) async {
  try {
    // Check if any products are using this category
    final relatedProducts = await (db.select(db.products)
          ..where((p) => p.categoryId.equals(id)))
        .get();

    if (relatedProducts.isNotEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'Cannot delete category with associated products',
          'productCount': relatedProducts.length,
        },
      );
    }

    // Check if any subcategories are using this as parent
    final subCategories = await (db.select(db.categories)
          ..where((c) => c.parentId.equals(id)))
        .get();

    if (subCategories.isNotEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'Cannot delete category with subcategories',
          'subcategoryCount': subCategories.length,
        },
      );
    }

    // Delete the category
    await (db.delete(db.categories)..where((c) => c.id.equals(id))).go();

    return Response.json(
      body: {
        'success': true,
        'message': 'Category deleted successfully',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'success': false,
        'message': 'Failed to delete category',
        'error': e.toString(),
      },
    );
  }
}

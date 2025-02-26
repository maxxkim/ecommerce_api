import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:ecommerce_api/database/database.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  final db = context.read<AppDatabase>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGetCategories(context, db);
    case HttpMethod.post:
      return _handleCreateCategory(context, db);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _handleGetCategories(
    RequestContext context, AppDatabase db) async {
  try {
    final categoriesQuery = db.select(db.categories);

    // Handle query parameters for filtering
    final queryParams = context.request.uri.queryParameters;
    if (queryParams.containsKey('active')) {
      final isActive = queryParams['active'] == 'true';
      categoriesQuery.where((category) => category.isActive.equals(isActive));
    }

    if (queryParams.containsKey('parent')) {
      final parentId = queryParams['parent'];
      if (parentId == 'null') {
        categoriesQuery.where((category) => category.parentId.isNull());
      } else {
        categoriesQuery
            .where((category) => category.parentId.equals(parentId ?? ''));
      }
    }

    // Execute query
    final categories = await categoriesQuery.get();

    return Response.json(
      body: {
        'success': true,
        'data': categories,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'success': false,
        'message': 'Failed to fetch categories',
        'error': e.toString(),
      },
    );
  }
}

Future<Response> _handleCreateCategory(
    RequestContext context, AppDatabase db) async {
  try {
    final json = await context.request.json() as Map<String, dynamic>;

    // Extract and validate required fields
    final name = json['name'] as String?;
    if (name == null || name.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'Category name is required',
        },
      );
    }

    final slug = json['slug'] as String? ?? _generateSlug(name);

    // Check if slug already exists
    final existingCategory = await (db.select(db.categories)
          ..where((c) => c.slug.equals(slug)))
        .getSingleOrNull();

    if (existingCategory != null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'A category with this slug already exists',
        },
      );
    }

    // Create new category
    final category = CategoriesCompanion.insert(
      name: name,
      slug: slug,
      description: Value(json['description'] as String? ?? ''),
      parentId: json['parentId'] != null
          ? Value(json['parentId'] as String)
          : const Value.absent(),
      isActive: Value(json['isActive'] as bool? ?? true),
    );

    final categoryId = await db.into(db.categories).insert(category);

    // Fetch the created category
    final createdCategory = await (db.select(db.categories)
          ..where((c) => c.id.equals(categoryId.toString())))
        .getSingle();

    return Response.json(
      statusCode: HttpStatus.created,
      body: {
        'success': true,
        'message': 'Category created successfully',
        'data': createdCategory,
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'success': false,
        'message': 'Failed to create category',
        'error': e.toString(),
      },
    );
  }
}

String _generateSlug(String name) {
  return name
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\s-]'), '')
      .replaceAll(RegExp(r'\s+'), '-');
}

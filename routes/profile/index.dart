import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:ecommerce_api/database/database.dart';
import 'package:ecommerce_api/models/app_user.dart';
import 'package:drift/drift.dart';

Future<Response> onRequest(RequestContext context) async {
  // Get authenticated user
  final currentUser = context.read<AppUser>();
  final db = context.read<AppDatabase>();

  switch (context.request.method) {
    case HttpMethod.get:
      return _handleGetProfile(context, db, currentUser);
    case HttpMethod.put:
    case HttpMethod.patch:
      return _handleUpdateProfile(context, db, currentUser);
    default:
      return Response(statusCode: HttpStatus.methodNotAllowed);
  }
}

Future<Response> _handleGetProfile(
  RequestContext context,
  AppDatabase db,
  AppUser currentUser,
) async {
  try {
    // Get latest user data from DB
    final user = await (db.select(db.users)
          ..where((u) => u.id.equals(currentUser.id)))
        .getSingle();

    // Get user addresses
    final addresses = await (db.select(db.addresses)
          ..where((a) => a.userId.equals(currentUser.id)))
        .get();

    // Get user orders
    final orders = await (db.select(db.orders)
          ..where((o) => o.userId.equals(currentUser.id))
          ..orderBy([(o) => OrderingTerm.desc(o.createdAt)]))
        .get();

    return Response.json(
      body: {
        'success': true,
        'data': {
          'user': AppUser.fromDB(user).toJson(),
          'addresses': addresses,
          'orderCount': orders.length,
        },
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'success': false,
        'message': 'Failed to fetch profile',
        'error': e.toString(),
      },
    );
  }
}

Future<Response> _handleUpdateProfile(
  RequestContext context,
  AppDatabase db,
  AppUser currentUser,
) async {
  try {
    final json = await context.request.json() as Map<String, dynamic>;

    // Prepare values for companion
    Value<String>? firstNameValue;
    Value<String>? lastNameValue;

    if (json.containsKey('firstName')) {
      final firstName = json['firstName'] as String?;
      if (firstName == null || firstName.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {
            'success': false,
            'message': 'First name cannot be empty',
          },
        );
      }
      firstNameValue = Value(firstName);
    }

    if (json.containsKey('lastName')) {
      final lastName = json['lastName'] as String?;
      if (lastName == null || lastName.isEmpty) {
        return Response.json(
          statusCode: HttpStatus.badRequest,
          body: {
            'success': false,
            'message': 'Last name cannot be empty',
          },
        );
      }
      lastNameValue = Value(lastName);
    }

    // Build companion with provided fields
    final updatedUser = UsersCompanion(
      id: Value(currentUser.id),
      firstName: firstNameValue ?? const Value.absent(),
      lastName: lastNameValue ?? const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    // Update user profile
    await db.update(db.users).replace(updatedUser);

    // Fetch updated user
    final user = await (db.select(db.users)
          ..where((u) => u.id.equals(currentUser.id)))
        .getSingle();

    return Response.json(
      body: {
        'success': true,
        'message': 'Profile updated successfully',
        'data': AppUser.fromDB(user).toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'success': false,
        'message': 'Failed to update profile',
        'error': e.toString(),
      },
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ecommerce_api/database/database.dart';

// This route is for development purposes only
// It initializes the database with basic tables and sample data
Future<Response> onRequest(RequestContext context) async {
  // Only allow POST requests to this endpoint
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final db = AppDatabase();

    // Create the tables
    await db.createTables();

    // Create admin user for testing
    await db.createAdminUser();

    return Response.json(
      body: {
        'success': true,
        'message': 'Database initialized successfully',
        'admin': {'email': 'admin@example.com', 'password': 'admin123'}
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'success': false,
        'message': 'Failed to initialize database',
        'error': e.toString()
      },
    );
  }
}

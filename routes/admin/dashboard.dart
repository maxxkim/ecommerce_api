import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:ecommerce_api/database/database.dart';
import 'package:ecommerce_api/models/app_user.dart';

Future<Response> onRequest(RequestContext context) async {
  // Only allow GET requests
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final db = context.read<AppDatabase>();
    final currentUser = context.read<AppUser>();

    // Get some basic dashboard stats using direct Drift select
    final userCount =
        await db.select(db.users).get().then((users) => users.length);

    return Response.json(
      body: {
        'stats': {
          'userCount': userCount,
          'adminUser': currentUser.toJson(),
        }
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {'message': 'Internal server error: ${e.toString()}'},
    );
  }
}

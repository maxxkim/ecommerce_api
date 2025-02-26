import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:ecommerce_api/services/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  // Only allow POST requests for token verification
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final authService = context.read<AuthService>();
    final requestBody = await context.request.json() as Map<String, dynamic>;

    // Validate required fields
    final token = requestBody['token'] as String?;

    if (token == null || token.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'Token is required',
        },
      );
    }

    // Verify token
    final user = await authService.verifyToken(token);

    if (user == null) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: {
          'success': false,
          'message': 'Invalid or expired token',
          'isValid': false,
        },
      );
    }

    return Response.json(
      body: {
        'success': true,
        'isValid': true,
        'user': user.toJson(),
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'success': false,
        'message': 'Failed to verify token',
        'error': e.toString(),
      },
    );
  }
}

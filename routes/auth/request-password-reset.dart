import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:ecommerce_api/services/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  // Only allow POST requests
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final authService = context.read<AuthService>();
    final requestBody = await context.request.json() as Map<String, dynamic>;

    // Validate required fields
    final email = requestBody['email'] as String?;

    if (email == null || email.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'Email is required',
        },
      );
    }

    // Request password reset
    final success = await authService.requestPasswordReset(email);

    if (!success) {
      // Don't reveal if the email exists or not for security reasons
      return Response.json(
        body: {
          'success': true,
          'message':
              'If your email exists in our system, you will receive a password reset link',
        },
      );
    }

    return Response.json(
      body: {
        'success': true,
        'message':
            'If your email exists in our system, you will receive a password reset link',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'success': false,
        'message': 'Failed to process password reset request',
        'error': e.toString(),
      },
    );
  }
}

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
    final token = requestBody['token'] as String?;
    final newPassword = requestBody['newPassword'] as String?;

    if (token == null || token.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'Reset token is required',
        },
      );
    }

    if (newPassword == null || newPassword.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'New password is required',
        },
      );
    }

    // Validate password strength
    if (newPassword.length < 8) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'Password must be at least 8 characters long',
        },
      );
    }

    // Reset password
    final success = await authService.resetPassword(token, newPassword);

    if (!success) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'Invalid or expired reset token',
        },
      );
    }

    return Response.json(
      body: {
        'success': true,
        'message': 'Password has been reset successfully',
      },
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'success': false,
        'message': 'Failed to reset password',
        'error': e.toString(),
      },
    );
  }
}

import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:ecommerce_api/services/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  // Only allow POST requests for login
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final authService = context.read<AuthService>();
    final requestBody = await context.request.json() as Map<String, dynamic>;

    // Validate required fields
    final email = requestBody['email'] as String?;
    final password = requestBody['password'] as String?;

    if (email == null ||
        email.isEmpty ||
        password == null ||
        password.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'Email and password are required',
        },
      );
    }

    // Attempt to login
    final result = await authService.login(
      email: email,
      password: password,
    );

    if (!result.success) {
      return Response.json(
        statusCode: HttpStatus.unauthorized,
        body: result.toJson(),
      );
    }

    return Response.json(body: result.toJson());
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'success': false,
        'message': 'Failed to login',
        'error': e.toString(),
      },
    );
  }
}

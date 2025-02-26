import 'dart:async';
import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:ecommerce_api/services/auth_service.dart';

Future<Response> onRequest(RequestContext context) async {
  // Only allow POST requests for registration
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final authService = context.read<AuthService>();
    final requestBody = await context.request.json() as Map<String, dynamic>;

    // Validate required fields
    final email = requestBody['email'] as String?;
    final password = requestBody['password'] as String?;
    final firstName = requestBody['firstName'] as String?;
    final lastName = requestBody['lastName'] as String?;

    if (email == null || email.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'Email is required',
        },
      );
    }

    if (password == null || password.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'Password is required',
        },
      );
    }

    if (firstName == null || firstName.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'First name is required',
        },
      );
    }

    if (lastName == null || lastName.isEmpty) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'Last name is required',
        },
      );
    }

    // Validate email format
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(email)) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'Invalid email format',
        },
      );
    }

    // Validate password strength
    if (password.length < 8) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: {
          'success': false,
          'message': 'Password must be at least 8 characters long',
        },
      );
    }

    // Attempt to register
    final result = await authService.register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    if (!result.success) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: result.toJson(),
      );
    }

    return Response.json(
      statusCode: HttpStatus.created,
      body: result.toJson(),
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: {
        'success': false,
        'message': 'Failed to register user',
        'error': e.toString(),
      },
    );
  }
}

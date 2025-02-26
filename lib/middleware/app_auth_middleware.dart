import 'dart:io';
import 'package:dart_frog/dart_frog.dart';
import 'package:ecommerce_api/models/app_user.dart';
import 'package:ecommerce_api/services/auth_service.dart';

// Authentication middleware
Middleware authMiddleware(AuthService authService) {
  return (handler) {
    return (context) async {
      // Get Authorization header
      final authHeader =
          context.request.headers[HttpHeaders.authorizationHeader];

      // If no Authorization header or doesn't start with Bearer, return 401
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: {'message': 'Authentication required'},
        );
      }

      // Extract token
      final token = authHeader.substring(7);

      // Verify token
      final user = await authService.verifyToken(token);

      if (user == null) {
        return Response.json(
          statusCode: HttpStatus.unauthorized,
          body: {'message': 'Invalid or expired token'},
        );
      }

      // Create a new context with the authenticated user
      final updatedContext = context.provide<AppUser>(() => user);

      // Proceed to the handler with updated context
      return handler(updatedContext);
    };
  };
}

// Role-based authorization middleware
Middleware roleMiddleware(List<String> allowedRoles) {
  return (handler) {
    return (context) async {
      // Get authenticated user from context
      final user = context.read<AppUser>();

      // Check if user role is in allowed roles
      if (!allowedRoles.contains(user.role)) {
        return Response.json(
          statusCode: HttpStatus.forbidden,
          body: {'message': 'Access denied: insufficient permissions'},
        );
      }

      // Proceed to the handler
      return handler(context);
    };
  };
}

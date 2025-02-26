import 'package:ecommerce_api/models/app_user.dart';

class AuthResult {
  final bool success;
  final String message;
  final AppUser? user;
  final String? token;

  AuthResult({
    required this.success,
    required this.message,
    required this.user,
    required this.token,
  });

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'user': user?.toJson(),
      'token': token,
    };
  }
}

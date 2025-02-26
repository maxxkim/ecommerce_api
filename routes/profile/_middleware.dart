import 'package:dart_frog/dart_frog.dart';
import 'package:ecommerce_api/database/database.dart';
import 'package:ecommerce_api/middleware/app_auth_middleware.dart';
import 'package:ecommerce_api/services/auth_service.dart';

final _db = AppDatabase();
final _authService = AuthService(_db);

Handler middleware(Handler handler) {
  return handler
      .use(provider<AppDatabase>((_) => _db))
      .use(provider<AuthService>((_) => _authService))
      .use(authMiddleware(_authService)); // Require authentication for profile
}

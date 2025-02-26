import 'dart:convert';
import 'package:bcrypt/bcrypt.dart';
import 'package:drift/drift.dart';
import 'package:ecommerce_api/database/database.dart';
import 'package:ecommerce_api/models/app_user.dart';
import 'package:ecommerce_api/models/auth_result.dart';
import 'package:jose/jose.dart';
import 'package:uuid/uuid.dart';

class AuthService {
  final AppDatabase _db;
  // In a real application, this should be stored securely in environment variables
  final String _jwtSecret = 'your_jwt_secret_key_here';

  AuthService(this._db);

  // Register a new user
  Future<AuthResult> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    // Check if email already exists
    final existingUser = await (_db.select(_db.users)
          ..where((u) => u.email.equals(email)))
        .getSingleOrNull();

    if (existingUser != null) {
      return AuthResult(
        success: false,
        message: 'Email already in use',
        user: null,
        token: null,
      );
    }

    // Hash password
    final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

    // Generate verification token
    final verificationToken = const Uuid().v4();

    // Create user
    final userId = DateTime.now().millisecondsSinceEpoch.toString();

    final user = UsersCompanion(
      id: Value(userId),
      email: Value(email),
      passwordHash: Value(passwordHash),
      firstName: Value(firstName),
      lastName: Value(lastName),
      verificationToken: Value(verificationToken),
    );

    await _db.into(_db.users).insert(user);

    // Get created user
    final createdUser = await (_db.select(_db.users)
          ..where((u) => u.id.equals(userId)))
        .getSingle();

    // Generate JWT token
    final token = _generateToken(createdUser);

    // TODO: Send verification email

    return AuthResult(
      success: true,
      message: 'Registration successful',
      user: AppUser.fromDB(createdUser),
      token: token,
    );
  }

  // Login user
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    // Find user by email
    final user = await (_db.select(_db.users)
          ..where((u) => u.email.equals(email)))
        .getSingleOrNull();

    if (user == null) {
      return AuthResult(
        success: false,
        message: 'Invalid credentials',
        user: null,
        token: null,
      );
    }

    // Verify password
    if (!BCrypt.checkpw(password, user.passwordHash)) {
      return AuthResult(
        success: false,
        message: 'Invalid credentials',
        user: null,
        token: null,
      );
    }

    // Check if user is active
    if (!user.isActive) {
      return AuthResult(
        success: false,
        message: 'Account is deactivated',
        user: null,
        token: null,
      );
    }

    // Update last login using companion
    final updateCompanion = UsersCompanion(
      id: Value(user.id),
      lastLogin: Value(DateTime.now()),
    );

    await _db.update(_db.users).replace(updateCompanion);

    // Generate JWT token
    final token = _generateToken(user);

    return AuthResult(
      success: true,
      message: 'Login successful',
      user: AppUser.fromDB(user),
      token: token,
    );
  }

  // Verify email
  Future<bool> verifyEmail(String token) async {
    final user = await (_db.select(_db.users)
          ..where((u) => u.verificationToken.equals(token)))
        .getSingleOrNull();

    if (user == null) {
      return false;
    }

    // Update user
    final updateCompanion = UsersCompanion(
      id: Value(user.id),
      isVerified: const Value(true),
      verificationToken: const Value(null),
    );

    await _db.update(_db.users).replace(updateCompanion);

    return true;
  }

  // Request password reset
  Future<bool> requestPasswordReset(String email) async {
    final user = await (_db.select(_db.users)
          ..where((u) => u.email.equals(email)))
        .getSingleOrNull();

    if (user == null) {
      return false;
    }

    final resetToken = const Uuid().v4();
    final expires = DateTime.now().add(const Duration(hours: 24));

    // Update user
    final updateCompanion = UsersCompanion(
      id: Value(user.id),
      resetPasswordToken: Value(resetToken),
      resetPasswordExpires: Value(expires),
    );

    await _db.update(_db.users).replace(updateCompanion);

    // TODO: Send password reset email

    return true;
  }

  // Reset password
  Future<bool> resetPassword(String token, String newPassword) async {
    final now = DateTime.now();

    // First get user with matching token
    final user = await (_db.select(_db.users)
          ..where((u) => u.resetPasswordToken.equals(token)))
        .getSingleOrNull();

    // Then check if token is expired
    if (user == null ||
        user.resetPasswordExpires == null ||
        user.resetPasswordExpires!.isBefore(now)) {
      return false;
    }

    final passwordHash = BCrypt.hashpw(newPassword, BCrypt.gensalt());

    // Update user
    final updateCompanion = UsersCompanion(
      id: Value(user.id),
      passwordHash: Value(passwordHash),
      resetPasswordToken: const Value(null),
      resetPasswordExpires: const Value(null),
    );

    await _db.update(_db.users).replace(updateCompanion);

    return true;
  }

  // Verify JWT token
  Future<AppUser?> verifyToken(String token) async {
    try {
      final jwk = JsonWebKey.fromJson({
        'kty': 'oct',
        'k': base64Url.encode(utf8.encode(_jwtSecret)),
      });

      final keyStore = JsonWebKeyStore()..addKey(jwk);

      final jwt = JsonWebToken.unverified(token);
      await jwt.verify(keyStore);

      final payload = jwt.claims;
      if (payload['exp'] is int &&
          DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000)
              .isBefore(DateTime.now())) {
        return null;
      }

      if (payload['sub'] is String) {
        final userId = payload['sub'] as String;
        final user = await (_db.select(_db.users)
              ..where((u) => u.id.equals(userId)))
            .getSingleOrNull();

        if (user != null && user.isActive) {
          return AppUser.fromDB(user);
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  // Generate JWT token
  String _generateToken(User user) {
    final builder = JsonWebSignatureBuilder()
      ..jsonContent = {
        'sub': user.id,
        'email': user.email,
        'role': user.role,
        'exp': (DateTime.now()
                .add(const Duration(days: 7))
                .millisecondsSinceEpoch ~/
            1000),
        'iat': (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      }
      ..addRecipient(
        JsonWebKey.fromJson({
          'kty': 'oct',
          'k': base64Url.encode(utf8.encode(_jwtSecret)),
        }),
        algorithm: 'HS256',
      );

    return builder.build().toString();
  }
}

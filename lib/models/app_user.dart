// Renamed from user.dart to app_user.dart to avoid conflicts

import 'package:ecommerce_api/database/database.dart';

class AppUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final DateTime? lastLogin;
  final bool isActive;

  AppUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.isVerified,
    this.lastLogin,
    required this.isActive,
  });

  // Factory constructor to create User from database object
  factory AppUser.fromDB(User data) {
    return AppUser(
      id: data.id,
      email: data.email,
      firstName: data.firstName,
      lastName: data.lastName,
      role: data.role,
      createdAt: data.createdAt,
      updatedAt: data.updatedAt,
      isVerified: data.isVerified,
      lastLogin: data.lastLogin,
      isActive: data.isActive,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVerified': isVerified,
      'lastLogin': lastLogin?.toIso8601String(),
      'isActive': isActive,
    };
  }

  // Check if user is admin
  bool get isAdmin => role == 'admin';

  // Get full name
  String get fullName => '$firstName $lastName';
}

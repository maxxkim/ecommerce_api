# Dart Frog eCommerce API

A robust backend API built with Dart Frog for eCommerce applications. This project demonstrates building a production-ready API service with Dart and showcases server-side development capabilities for Flutter developers.

## Features

### Authentication & Authorization
- User registration and login with JWT authentication
- Password hashing with bcrypt
- Role-based access control (admin, customer)
- Password reset functionality

### Product Management
- CRUD operations for products
- Category management
- Support for product attributes and variants
- Image handling

### User Profile Management
- View and update user information
- Multiple shipping address management
- Order history

### Order System
- Shopping cart implementation
- Checkout process
- Order tracking and history
- Payment processing

### Database
- SQLite with Drift ORM
- Type-safe database operations
- Migrations support

## Tech Stack

- **Dart Frog**: Backend framework
- **Drift**: Type-safe SQLite ORM
- **JWT**: Authentication tokens
- **bcrypt**: Password hashing

## Getting Started

### Prerequisites
- Dart SDK 3.0.0+
- Git

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/dart-frog-ecommerce-api.git
cd dart-frog-ecommerce-api
```

2. Install dependencies:
```bash
dart pub get
```

3. Generate database code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Start the development server:
```bash
dart_frog dev
```

The server will be running at http://localhost:8080

### Initialize Database

To initialize the database with required tables and an admin user, send a POST request to `/init-db`:

```bash
curl -X POST http://localhost:8080/init-db
```

This will create:
- All necessary database tables
- An admin user with:
  - Email: admin@example.com
  - Password: admin123

## API Documentation

### Authentication

#### Register a new user
```
POST /auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "firstName": "John",
  "lastName": "Doe"
}
```

#### Login
```
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

Response includes JWT token to use for authenticated requests:
```json
{
  "success": true,
  "message": "Login successful",
  "user": { ... },
  "token": "your.jwt.token"
}
```

#### Verify Token
```
POST /auth/verify-token
Content-Type: application/json

{
  "token": "your.jwt.token"
}
```

#### Request Password Reset
```
POST /auth/request-password-reset
Content-Type: application/json

{
  "email": "user@example.com"
}
```

#### Reset Password
```
POST /auth/reset-password
Content-Type: application/json

{
  "token": "reset-token",
  "newPassword": "newpassword123"
}
```

### Categories

#### Get All Categories
```
GET /categories
```

Optional query parameters:
- `active=true` - Only active categories
- `parent=categoryId` - Categories under specific parent
- `parent=null` - Top-level categories

#### Create Category
```
POST /categories
Content-Type: application/json
Authorization: Bearer your.jwt.token

{
  "name": "Electronics",
  "description": "Electronic devices",
  "slug": "electronics",
  "parentId": null,
  "isActive": true
}
```

#### Get Category
```
GET /categories/{id}
```

#### Update Category
```
PUT /categories/{id}
Content-Type: application/json
Authorization: Bearer your.jwt.token

{
  "name": "Updated Electronics",
  "isActive": true
}
```

#### Delete Category
```
DELETE /categories/{id}
Authorization: Bearer your.jwt.token
```

### User Profile

#### Get Profile
```
GET /profile
Authorization: Bearer your.jwt.token
```

#### Update Profile
```
PUT /profile
Content-Type: application/json
Authorization: Bearer your.jwt.token

{
  "firstName": "Updated",
  "lastName": "Name"
}
```

### Admin Dashboard

#### Dashboard Stats
```
GET /admin/dashboard
Authorization: Bearer your.jwt.token
```
Note: Requires admin role

## Testing with Postman

1. Import the provided Postman collection (if available) or create a new collection
2. Use the following flow to test:
   - Initialize database with POST to `/init-db`
   - Login as admin using `/auth/login`
   - Add the JWT token to your requests using the Authorization header
   - Test other endpoints

## Project Structure

```
├── lib/
│   ├── database/
│   │   ├── tables/         # Database table definitions
│   │   └── database.dart   # Main database configuration
│   ├── middleware/         # Custom middleware (auth, etc)
│   ├── models/             # Data models
│   └── services/           # Business logic
├── routes/                 # API endpoints
│   ├── admin/              # Admin-only routes
│   ├── auth/               # Authentication routes
│   ├── categories/         # Category management
│   ├── profile/            # User profile routes
│   └── ...
└── test/                   # Tests
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgements

- [Dart Frog](https://dartfrog.vgv.dev/)
- [Drift](https://drift.simonbinder.eu/)

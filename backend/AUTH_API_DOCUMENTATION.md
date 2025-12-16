# Authentication API Documentation

Complete documentation for JWT-based authentication system.

## Base URL

```
http://localhost:3000/api/auth
```

## Table of Contents

- [Authentication Flow](#authentication-flow)
- [Security Features](#security-features)
- [Endpoints](#endpoints)
  - [Register](#post-register)
  - [Login](#post-login)
  - [Logout](#post-logout)
  - [Get Current User](#get-me)
  - [Refresh Token](#post-refresh-token)
  - [Request Password Reset](#post-request-password-reset)
  - [Reset Password](#post-reset-password)
  - [Change Password](#post-change-password)
  - [Send Email Verification](#post-send-verification-email)
  - [Verify Email](#post-verify-email)
- [Error Codes](#error-codes)
- [Rate Limiting](#rate-limiting)

## Authentication Flow

### Standard Flow

1. **Register/Login** → Receive `accessToken` and `refreshToken`
2. **Store Tokens** → Save in secure storage (Flutter: `flutter_secure_storage`)
3. **Use Access Token** → Include in `Authorization: Bearer <token>` header
4. **Token Expires** → Use `refreshToken` to get new tokens
5. **Logout** → Token is blacklisted

### Token Lifetimes

- **Access Token**: 7 days (configurable)
- **Refresh Token**: 30 days (configurable)
- **Reset Token**: 1 hour
- **Verification Token**: 24 hours

## Security Features

✅ **JWT-based authentication** with access and refresh tokens  
✅ **Bcrypt password hashing** (10 rounds)  
✅ **Token blacklisting** on logout  
✅ **Rate limiting** on sensitive endpoints  
✅ **Password complexity validation**  
✅ **Email verification** support  
✅ **Password reset** with secure tokens  
✅ **Role-based access control** (RBAC)  
✅ **Clinic-based authorization**  
✅ **CORS and Helmet** security headers

---

## Endpoints

### POST /register

Register a new user account.

**Rate Limit:** 5 requests per hour per IP

**Request:**

```json
{
  "email": "doctor@example.com",
  "password": "SecurePass123",
  "fullName": "Dr. John Doe",
  "phone": "+1234567890",
  "role": "user",
  "clinicId": "uuid-here" // Optional
}
```

**Validation Rules:**

- `email`: Valid email format
- `password`: Min 8 chars, must contain uppercase, lowercase, and number
- `fullName`: Required, non-empty
- `role`: Optional, must be one of: `admin`, `user`, `operator`

**Response (201):**

```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "user": {
      "id": "uuid",
      "email": "doctor@example.com",
      "fullName": "Dr. John Doe",
      "phone": "+1234567890",
      "role": "user",
      "clinicId": null
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Responses:**

- `409`: Email already exists
- `400`: Validation errors

---

### POST /login

Authenticate a user and receive tokens.

**Rate Limit:** 5 requests per 15 minutes per IP (only failed attempts count)

**Request:**

```json
{
  "email": "doctor@example.com",
  "password": "SecurePass123"
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": "uuid",
      "email": "doctor@example.com",
      "fullName": "Dr. John Doe",
      "phone": "+1234567890",
      "avatar": null,
      "role": "user",
      "clinicId": "uuid",
      "emailVerified": false
    },
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Responses:**

- `401`: Invalid email or password
- `403`: Account is deactivated

---

### POST /logout

Logout user and invalidate token.

**Authentication:** Required

**Headers:**

```
Authorization: Bearer <accessToken>
```

**Request:** Empty body or optional:

```json
{}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Logout successful"
}
```

**Notes:**

- Token is added to blacklist
- Blacklisted tokens cannot be reused
- Blacklist entry auto-expires when token naturally expires

---

### GET /me

Get current authenticated user's information.

**Authentication:** Required

**Headers:**

```
Authorization: Bearer <accessToken>
```

**Response (200):**

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "doctor@example.com",
    "fullName": "Dr. John Doe",
    "phone": "+1234567890",
    "avatar": null,
    "role": "user",
    "clinicId": "uuid",
    "emailVerified": false,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "lastLogin": "2024-01-15T10:30:00.000Z"
  }
}
```

**Error Responses:**

- `401`: Invalid or expired token
- `404`: User not found

---

### POST /refresh-token

Get new access token using refresh token.

**Request:**

```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200):**

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

**Error Responses:**

- `400`: Refresh token is required
- `401`: Invalid or expired refresh token

**Usage in Flutter:**

```dart
if (response.statusCode == 401) {
  // Access token expired, refresh it
  final newTokens = await refreshToken(storedRefreshToken);
  // Retry original request with new access token
}
```

---

### POST /request-password-reset

Request a password reset email.

**Rate Limit:** 3 requests per hour per IP

**Request:**

```json
{
  "email": "doctor@example.com"
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "If an account with that email exists, a password reset link has been sent."
}
```

**Notes:**

- Always returns success to prevent email enumeration attacks
- Reset link expires in 1 hour
- Email contains reset token

**Email Content:**

- Subject: "Password Reset Request - Clinic App"
- Contains link: `{FRONTEND_URL}/reset-password?token={resetToken}`

---

### POST /reset-password

Reset password using token from email.

**Request:**

```json
{
  "token": "abc123...",
  "newPassword": "NewSecurePass123"
}
```

**Validation:**

- `newPassword`: Min 8 chars, must contain uppercase, lowercase, and number

**Response (200):**

```json
{
  "success": true,
  "message": "Password has been reset successfully. You can now login with your new password."
}
```

**Error Responses:**

- `400`: Invalid or expired reset token
- `400`: Password validation failed

---

### POST /change-password

Change password for authenticated user.

**Authentication:** Required

**Headers:**

```
Authorization: Bearer <accessToken>
```

**Request:**

```json
{
  "currentPassword": "OldPass123",
  "newPassword": "NewSecurePass123"
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Password changed successfully"
}
```

**Error Responses:**

- `401`: Current password is incorrect
- `400`: Password validation failed

---

### POST /send-verification-email

Send email verification link to user.

**Authentication:** Required

**Headers:**

```
Authorization: Bearer <accessToken>
```

**Request:** Empty body

**Response (200):**

```json
{
  "success": true,
  "message": "Verification email has been sent"
}
```

**Error Responses:**

- `400`: Email is already verified
- `500`: Failed to send email

---

### POST /verify-email

Verify email using token from email.

**Request:**

```json
{
  "token": "abc123..."
}
```

**Response (200):**

```json
{
  "success": true,
  "message": "Email verified successfully"
}
```

**Error Responses:**

- `400`: Invalid or expired verification token

---

## Error Codes

### 400 Bad Request

- Missing required fields
- Invalid input format
- Token expired

### 401 Unauthorized

- Invalid credentials
- Missing or invalid token
- Token blacklisted

### 403 Forbidden

- Account deactivated
- Email not verified (if required)
- Insufficient permissions

### 404 Not Found

- User not found
- Resource not found

### 409 Conflict

- Email already exists

### 429 Too Many Requests

- Rate limit exceeded

### 500 Internal Server Error

- Server error (check logs)

---

## Rate Limiting

### General API

- **Limit:** 100 requests per 15 minutes per IP
- **Applies to:** All `/api/*` routes

### Authentication Endpoints

| Endpoint                       | Limit                          |
| ------------------------------ | ------------------------------ |
| POST /login                    | 5 per 15 min (failed only)     |
| POST /register                 | 5 per hour                     |
| POST /request-password-reset   | 3 per hour                     |

### Rate Limit Headers

```
RateLimit-Limit: 100
RateLimit-Remaining: 95
RateLimit-Reset: 1234567890
```

---

## Middleware Usage

### Authentication Middleware

Protect routes that require authentication:

```javascript
import { authenticate } from '../middleware/auth.js';

router.get('/protected', authenticate, controller.method);
```

### Role-Based Authorization

Restrict access by user role:

```javascript
import { authenticate, requireRole } from '../middleware/auth.js';

router.post('/admin-only', 
  authenticate, 
  requireRole('admin'), 
  controller.method
);
```

### Clinic Authorization

Ensure users can only access their clinic's data:

```javascript
import { authenticate } from '../middleware/auth.js';
import { validateClinicAccess } from '../middleware/clinicAuth.js';

router.get('/clinics/:clinicId/data', 
  authenticate, 
  validateClinicAccess, 
  controller.method
);
```

---

## Flutter Integration Example

### Setup

```dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000/api',
  ));
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  ApiService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add token to all requests
        final token = await _storage.read(key: 'accessToken');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          // Token expired, try refresh
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry original request
            return handler.resolve(await _retry(error.requestOptions));
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    
    // Save tokens
    await _storage.write(
      key: 'accessToken', 
      value: response.data['data']['accessToken']
    );
    await _storage.write(
      key: 'refreshToken', 
      value: response.data['data']['refreshToken']
    );
    
    return response.data;
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refreshToken');
      final response = await _dio.post('/auth/refresh-token', data: {
        'refreshToken': refreshToken,
      });
      
      await _storage.write(
        key: 'accessToken', 
        value: response.data['data']['accessToken']
      );
      await _storage.write(
        key: 'refreshToken', 
        value: response.data['data']['refreshToken']
      );
      
      return true;
    } catch (e) {
      // Refresh failed, user needs to login again
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
    await _storage.deleteAll();
  }
}
```

---

## Security Best Practices

### For Backend

1. **Always use HTTPS in production**
2. **Keep JWT secrets secure** - Use strong, random strings
3. **Set appropriate token expiration times**
4. **Implement rate limiting** on all endpoints
5. **Log authentication attempts** for security monitoring
6. **Use bcrypt for password hashing** (never store plain text)
7. **Validate all inputs** with express-validator
8. **Keep dependencies updated** - Run `npm audit` regularly

### For Flutter App

1. **Use flutter_secure_storage** for tokens (not SharedPreferences)
2. **Implement automatic token refresh**
3. **Clear tokens on logout**
4. **Handle 401 errors gracefully** - Prompt user to login
5. **Never log tokens** in production
6. **Use SSL pinning** for production API calls
7. **Implement biometric authentication** for better UX

---

## Testing

### Using Postman/Insomnia

1. **Register User:**
   ```
   POST http://localhost:3000/api/auth/register
   Content-Type: application/json
   
   {
     "email": "test@example.com",
     "password": "TestPass123",
     "fullName": "Test User"
   }
   ```

2. **Save the tokens from response**

3. **Use token in subsequent requests:**
   ```
   GET http://localhost:3000/api/auth/me
   Authorization: Bearer <your-access-token>
   ```

### Using curl

```bash
# Register
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"TestPass123","fullName":"Test User"}'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"TestPass123"}'

# Get current user (replace <token> with actual token)
curl http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer <token>"
```

---

## Troubleshooting

### "Invalid or expired token"

- Token may have expired - use refresh token
- Token may be blacklisted after logout
- Check if Authorization header is correctly formatted: `Bearer <token>`

### "Too many requests"

- Rate limit reached - wait for the time window to reset
- Check `RateLimit-Reset` header for reset time

### "Email not sent"

- Check SMTP configuration in `.env`
- Verify email credentials
- Check server logs for detailed error

### "Password doesn't meet requirements"

- Must be at least 8 characters
- Must contain uppercase letter
- Must contain lowercase letter
- Must contain number

---

## Configuration

Environment variables in `.env`:

```env
# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRATION=7d
REFRESH_TOKEN_SECRET=your-refresh-secret
REFRESH_TOKEN_EXPIRATION=30d

# Email
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASSWORD=your-app-password
EMAIL_FROM=noreply@clinicapp.com
FRONTEND_URL=http://localhost:8080

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

---

## Support

For issues or questions:

- Check server logs: `npm run dev`
- Review this documentation
- Check PostgreSQL connection
- Verify environment variables

---

**Version:** 1.0.0  
**Last Updated:** December 16, 2024


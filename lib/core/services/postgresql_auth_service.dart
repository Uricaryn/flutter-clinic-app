import 'dart:async';
import 'package:clinic_app/core/services/api_service.dart';
import 'package:clinic_app/core/config/api_config.dart';
import 'package:clinic_app/core/services/logger_service.dart';
import 'package:clinic_app/core/services/base_auth_service.dart';

/// Authentication service for PostgreSQL backend with JWT
class PostgresqlAuthService implements BaseAuthService {
  final ApiService _apiService = ApiService();
  final _logger = LoggerService();

  // Stream controller for auth state changes
  final StreamController<PostgresqlUser?> _authStateController =
      StreamController<PostgresqlUser?>.broadcast();

  PostgresqlUser? _currentUser;

  /// Stream of authentication state changes
  Stream<PostgresqlUser?> get authStateChanges => _authStateController.stream;

  /// Get current authenticated user
  PostgresqlUser? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentUser != null;

  /// Initialize service and check for existing session
  Future<void> initialize() async {
    try {
      final token = await _apiService.getToken();
      if (token != null) {
        // Try to get current user
        final user = await getCurrentUser();
        if (user != null) {
          _setCurrentUser(user);
        }
      }
    } catch (e) {
      _logger.error('Error initializing auth service', e, StackTrace.current);
    }
  }

  /// Sign in with email and password
  Future<PostgresqlUser> signIn(String email, String password) async {
    try {
      _logger.info('Attempting sign in: $email');

      final response = await _apiService.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Backend wraps response in 'data' field
        final data = responseData['data'] ?? responseData;

        // Store tokens
        await _apiService.setTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );

        // Create user object
        final user = PostgresqlUser.fromJson(data['user']);
        _setCurrentUser(user);

        _logger.info('Sign in successful: ${user.id}');
        return user;
      } else {
        throw 'Sign in failed: ${response.statusMessage}';
      }
    } catch (e) {
      _logger.error('Sign in error', e, StackTrace.current);
      rethrow;
    }
  }

  /// Register new user
  Future<PostgresqlUser> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? phone,
    String? clinicId,
  }) async {
    try {
      _logger.info('Attempting registration: $email');

      final response = await _apiService.post(
        ApiConfig.registerEndpoint,
        data: {
          'email': email,
          'password': password,
          'fullName': fullName,
          'role': role,
          if (phone != null) 'phone': phone,
          if (clinicId != null) 'clinicId': clinicId,
        },
      );

      if (response.statusCode == 201) {
        final responseData = response.data;

        // Backend wraps response in 'data' field
        final data = responseData['data'] ?? responseData;

        // Store tokens
        await _apiService.setTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );

        // Create user object
        final user = PostgresqlUser.fromJson(data['user']);
        _setCurrentUser(user);

        _logger.info('Registration successful: ${user.id}');
        return user;
      } else {
        throw 'Registration failed: ${response.statusMessage}';
      }
    } catch (e) {
      _logger.error('Registration error', e, StackTrace.current);
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _logger.info('Signing out user: ${_currentUser?.id}');

      try {
        await _apiService.post(ApiConfig.logoutEndpoint);
      } catch (e) {
        // Logout endpoint might fail, but we should still clear local state
        _logger.warning('Logout endpoint failed: $e');
      }

      await _apiService.clearTokens();
      _setCurrentUser(null);

      _logger.info('Sign out successful');
    } catch (e) {
      _logger.error('Sign out error', e, StackTrace.current);
      rethrow;
    }
  }

  /// Get current user from backend
  Future<PostgresqlUser?> getCurrentUser() async {
    try {
      final response = await _apiService.get(ApiConfig.meEndpoint);

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Backend wraps response in 'data' field
        final data = responseData['data'] ?? responseData;

        final user =
            PostgresqlUser.fromJson(data['user'] ?? responseData['user']);
        _setCurrentUser(user);
        return user;
      }

      return null;
    } catch (e) {
      _logger.error('Get current user error', e, StackTrace.current);
      return null;
    }
  }

  /// Request password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.info('Requesting password reset for: $email');

      await _apiService.post(
        '/auth/reset-password',
        data: {'email': email},
      );

      _logger.info('Password reset email sent');
    } catch (e) {
      _logger.error('Password reset error', e, StackTrace.current);
      rethrow;
    }
  }

  /// Update user profile
  Future<void> updateProfile(Map<String, dynamic> data) async {
    try {
      if (_currentUser == null) {
        throw 'No user signed in';
      }

      _logger.info('Updating profile for: ${_currentUser!.id}');

      final response = await _apiService.put(
        '/auth/profile',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        // Backend wraps response in 'data' field
        final data = responseData['data'] ?? responseData;

        final updatedUser =
            PostgresqlUser.fromJson(data['user'] ?? responseData['user']);
        _setCurrentUser(updatedUser);
        _logger.info('Profile updated successfully');
      }
    } catch (e) {
      _logger.error('Profile update error', e, StackTrace.current);
      rethrow;
    }
  }

  /// Set current user and notify listeners
  void _setCurrentUser(PostgresqlUser? user) {
    _currentUser = user;
    _authStateController.add(user);
  }

  /// Dispose resources
  void dispose() {
    _authStateController.close();
  }

  // ============================================================================
  // BaseAuthService implementation (adapter methods for compatibility)
  // ============================================================================

  /// Adapter for signIn - matches BaseAuthService interface
  @override
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await signIn(email, password);
  }

  // Note: signOut() and sendPasswordResetEmail() already exist and match the interface

  @override
  Future<void> verifyEmail() async {
    // Email verification - resend verification email
    if (_currentUser == null) {
      throw 'No user signed in';
    }

    try {
      await _apiService.post(
        '/auth/resend-verification',
        data: {'email': _currentUser!.email},
      );
      _logger.info('Verification email resent');
    } catch (e) {
      _logger.error('Resend verification email error', e, StackTrace.current);
      rethrow;
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_currentUser == null) {
      throw 'No user signed in';
    }

    try {
      _logger.info('Changing password for user: ${_currentUser!.id}');

      await _apiService.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );

      _logger.info('Password changed successfully');
    } catch (e) {
      _logger.error('Change password error', e, StackTrace.current);
      rethrow;
    }
  }
}

/// User model for PostgreSQL backend
class PostgresqlUser {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String? avatar;
  final String role;
  final String? clinicId;
  final String? clinicName;
  final bool isActive;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;

  PostgresqlUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    this.avatar,
    required this.role,
    this.clinicId,
    this.clinicName,
    this.isActive = true,
    this.emailVerified = false,
    required this.createdAt,
    this.updatedAt,
    this.lastLogin,
  });

  /// Alias for id (backward compatibility with Firebase User.uid)
  String get uid => id;

  factory PostgresqlUser.fromJson(Map<String, dynamic> json) {
    return PostgresqlUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      role: json['role'] as String,
      clinicId: json['clinicId'] as String?,
      clinicName: json['clinicName'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      emailVerified: json['emailVerified'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      lastLogin: json['lastLogin'] != null
          ? DateTime.parse(json['lastLogin'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'avatar': avatar,
      'role': role,
      'clinicId': clinicId,
      'clinicName': clinicName,
      'isActive': isActive,
      'emailVerified': emailVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  PostgresqlUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phone,
    String? avatar,
    String? role,
    String? clinicId,
    String? clinicName,
    bool? isActive,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
  }) {
    return PostgresqlUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      clinicId: clinicId ?? this.clinicId,
      clinicName: clinicName ?? this.clinicName,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}

/// Email Service - Stubbed
/// 
/// Firebase Auth email verification has been removed.
/// Email verification is now handled by the PostgreSQL backend.

class EmailService {
  // Email verification is handled by backend API
  // See: lib/core/services/postgresql_auth_service.dart
  
  Future<void> sendVerificationEmail(String email) async {
    throw UnimplementedError(
      'Email verification is handled by backend API. '
      'Use PostgresqlAuthService.verifyEmail() instead.'
    );
  }

  Future<void> sendPasswordResetEmail(String email) async {
    throw UnimplementedError(
      'Password reset is handled by backend API.'
    );
  }
}

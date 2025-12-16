/// Base interface for authentication services
///
/// This ensures both FirebaseAuthService and PostgresqlAuthService
/// have compatible method signatures for common operations.

abstract class BaseAuthService {
  /// Sign in with email and password
  Future<void> signInWithEmailAndPassword(String email, String password);

  /// Sign out current user
  Future<void> signOut();

  /// Send email verification
  Future<void> verifyEmail();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);
}

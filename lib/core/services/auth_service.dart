import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:clinic_app/core/services/logger_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _logger = LoggerService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      _logger.info('Attempting to sign in user: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.info('User signed in successfully: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      _logger.error(
          'Firebase Auth Error during sign in', e, StackTrace.current);
      throw _handleAuthException(e);
    } catch (e) {
      _logger.error('Unexpected error during sign in', e, StackTrace.current);
      throw 'An unexpected error occurred. Please try again.';
    }
  }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String fullName,
    String role,
  ) async {
    UserCredential? credential;
    try {
      _logger.info('Attempting to register new user: $email');

      // Create user in Firebase Auth
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _logger.info('User created successfully: ${credential.user?.uid}');

      // Update user profile with name
      await credential.user?.updateDisplayName(fullName);
      _logger.info('User profile updated with name: $fullName');

      // Send verification email
      await credential.user?.sendEmailVerification();
      _logger.info('Verification email sent to: $email');

      // Create user document in Firestore
      try {
        _logger.info(
            'Attempting to create Firestore document for user: ${credential.user!.uid}');
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'fullName': fullName,
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'emailVerified': false,
        });
        _logger.info('User document created successfully in Firestore');
      } catch (firestoreError) {
        _logger.error('Firestore Error: Failed to create user document',
            firestoreError, StackTrace.current);
        // Re-throw the error to be caught by the outer catch block
        throw 'Failed to create user document in database: $firestoreError';
      }

      // Sign out after registration
      await _auth.signOut();
      _logger.info('User signed out after registration');

      return credential;
    } on FirebaseAuthException catch (e) {
      _logger.error(
          'Firebase Auth Error during registration', e, StackTrace.current);
      throw _handleAuthException(e);
    } catch (e) {
      _logger.error(
          'Unexpected error during registration', e, StackTrace.current);
      // If user creation fails or Firestore operation fails, clean up
      if (credential?.user != null) {
        try {
          await credential!.user!.delete();
          _logger.info('Deleted user after failed registration');
        } catch (deleteError) {
          _logger.error('Failed to delete user after failed registration',
              deleteError, StackTrace.current);
        }
      }
      throw 'Failed to create user account. Please try again.';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _logger.info('Attempting to sign out user: ${_auth.currentUser?.uid}');
      await _auth.signOut();
      _logger.info('User signed out successfully');
    } catch (e) {
      _logger.error('Error during sign out', e, StackTrace.current);
      throw 'Failed to sign out: $e';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _logger.info('Attempting to send password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email);
      _logger.info('Password reset email sent successfully');
    } catch (e) {
      _logger.error(
          'Error sending password reset email', e, StackTrace.current);
      throw _handleAuthException(e);
    }
  }

  // Verify email
  Future<void> verifyEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        _logger.info('Attempting to send verification email to: ${user.email}');
        await user.sendEmailVerification();
        _logger.info('Verification email sent successfully');
      } else {
        _logger.warning('No user is currently signed in');
        throw 'No user is currently signed in';
      }
    } catch (e) {
      _logger.error('Error sending verification email', e, StackTrace.current);
      throw _handleAuthException(e);
    }
  }

  // Reload user
  Future<void> reloadUser() async {
    try {
      _logger.info('Attempting to reload user data');
      await _auth.currentUser?.reload();
      _logger.info('User data reloaded successfully');
    } on FirebaseAuthException catch (e) {
      _logger.error(
          'Firebase Auth Error during user reload', e, StackTrace.current);
      throw _handleAuthException(e);
    } catch (e) {
      _logger.error(
          'Unexpected error during user reload', e, StackTrace.current);
      throw 'Failed to reload user data: $e';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      _logger.warning('Handling Firebase Auth Exception: ${e.code}');
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'The email address is already in use.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        case 'weak-password':
          return 'The password is too weak.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    return 'An error occurred. Please try again.';
  }
}

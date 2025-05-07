import 'package:firebase_auth/firebase_auth.dart';

class EmailService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Send verification email with custom template
  Future<void> sendVerificationEmail() async {
    try {
      final user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification(
          ActionCodeSettings(
            url: 'https://your-clinic-app.web.app/verify-email',
            handleCodeInApp: true,
            androidPackageName: 'com.example.clinic_app',
            androidInstallApp: true,
            androidMinimumVersion: '1',
            iOSBundleId: 'com.example.clinicApp',
          ),
        );
      }
    } catch (e) {
      throw 'Failed to send verification email: $e';
    }
  }

  // Send password reset email with custom template
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(
        email: email,
        actionCodeSettings: ActionCodeSettings(
          url: 'https://your-clinic-app.web.app/reset-password',
          handleCodeInApp: true,
          androidPackageName: 'com.example.clinic_app',
          androidInstallApp: true,
          androidMinimumVersion: '1',
          iOSBundleId: 'com.example.clinicApp',
        ),
      );
    } catch (e) {
      throw 'Failed to send password reset email: $e';
    }
  }

  // Send welcome email after registration
  Future<void> sendWelcomeEmail(String email) async {
    try {
      // Note: This requires a custom Cloud Function to send welcome emails
      // as Firebase Auth doesn't provide a direct way to send custom welcome emails
      // You would need to implement this using Firebase Cloud Functions
      // and a service like SendGrid or Firebase Extensions
    } catch (e) {
      throw 'Failed to send welcome email: $e';
    }
  }
}

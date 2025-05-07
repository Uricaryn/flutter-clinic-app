import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // Log a non-fatal error
  Future<void> logError(
    dynamic error,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: reason,
    );
  }

  // Set user identifier
  Future<void> setUserIdentifier(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }

  // Set custom key
  Future<void> setCustomKey(String key, dynamic value) async {
    await _crashlytics.setCustomKey(key, value);
  }

  // Log a message
  Future<void> log(String message) async {
    await _crashlytics.log(message);
  }

  // Force a crash for testing
  void forceCrash() {
    _crashlytics.crash();
  }
}

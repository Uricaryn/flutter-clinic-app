/// Database mode configuration for the app
///
/// This allows the app to switch between Firebase and PostgreSQL
/// without changing the codebase.
///
/// To change the mode:
/// 1. At compile time: flutter run --dart-define=DB_MODE=postgresql
/// 2. Or change the default value below

enum DatabaseMode {
  /// Use Firebase/Firestore (current production system)
  firebase,

  /// Use PostgreSQL with REST API backend
  postgresql,
}

class AppMode {
  AppMode._();

  /// Current database mode
  ///
  /// Can be overridden at build time with --dart-define=DB_MODE=postgresql
  static DatabaseMode get databaseMode {
    const String? envMode = String.fromEnvironment('DB_MODE', defaultValue: '');

    if (envMode.toLowerCase() == 'postgresql') {
      return DatabaseMode.postgresql;
    } else if (envMode.toLowerCase() == 'firebase') {
      return DatabaseMode.firebase;
    }

    // Default mode (change this when ready to switch)
    return _defaultMode;
  }

  /// Default database mode when no environment variable is set
  ///
  /// ⚠️ Change this to DatabaseMode.postgresql when ready to migrate
  static const DatabaseMode _defaultMode = DatabaseMode.firebase;

  /// Check if currently using Firebase
  static bool get isFirebase => databaseMode == DatabaseMode.firebase;

  /// Check if currently using PostgreSQL
  static bool get isPostgreSQL => databaseMode == DatabaseMode.postgresql;

  /// Get human-readable mode name
  static String get modeName {
    switch (databaseMode) {
      case DatabaseMode.firebase:
        return 'Firebase';
      case DatabaseMode.postgresql:
        return 'PostgreSQL';
    }
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/config/app_mode.dart';
import 'package:clinic_app/core/services/database_service.dart';
import 'package:clinic_app/core/services/firebase_database_service.dart';
import 'package:clinic_app/core/services/postgresql_database_service.dart';

/// Database service provider that selects implementation based on AppMode
///
/// Returns:
/// - FirebaseDatabaseService when in Firebase mode
/// - PostgresqlDatabaseService when in PostgreSQL mode
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  if (AppMode.isFirebase) {
    return FirebaseDatabaseService();
  } else {
    return PostgresqlDatabaseService();
  }
});

/// Convenience provider for database service instance
final databaseProvider = Provider<DatabaseService>((ref) {
  return ref.watch(databaseServiceProvider);
});


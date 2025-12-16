import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Database provider placeholder
/// 
/// This file is kept for backward compatibility but is no longer used
/// since we migrated from Firebase to PostgreSQL.
/// 
/// All database operations should now go through the backend API.

/// Deprecated: Use backend API services instead
@Deprecated('Use backend API services instead')
final databaseServiceProvider = Provider((ref) {
  throw UnimplementedError('Database provider is deprecated. Use backend API services.');
});

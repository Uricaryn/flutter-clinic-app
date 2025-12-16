import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub providers for features not yet implemented in PostgreSQL backend
/// 
/// These providers replace Firebase stream providers with empty streams
/// TODO: Implement with backend API calls

/// Procedures stream provider - STUB
final proceduresStreamProvider = StreamProvider<List<dynamic>>((ref) {
  // TODO: Implement with backend /api/procedures endpoint
  return Stream.value([]);
});

/// Stock items stream provider - STUB
final stockItemsStreamProvider = StreamProvider<List<dynamic>>((ref) {
  // TODO: Implement with backend /api/stock endpoint
  return Stream.value([]);
});

/// Users stream provider - STUB
final usersStreamProvider = StreamProvider<List<dynamic>>((ref) {
  // TODO: Implement with backend /api/users endpoint
  return Stream.value([]);
});

/// Clinic service provider - STUB
final clinicServiceProvider = Provider((ref) {
  // TODO: Implement ClinicService for backend API
  return _StubService();
});

/// Admin stats provider - STUB
final adminStatsProvider = Provider((ref) {
  // TODO: Implement admin stats from backend
  return {};
});

/// Clinic list provider - STUB
final clinicListProvider = Provider((ref) {
  // TODO: Implement with backend /api/clinics endpoint
  return [];
});

/// User list provider - STUB
final userListProvider = Provider((ref) {
  // TODO: Implement with backend /api/users endpoint
  return [];
});

class _StubService {
  Future<void> updateClinic(String id, Map<String, dynamic> data) async {
    throw UnimplementedError('Clinic update not yet implemented in backend');
  }
}

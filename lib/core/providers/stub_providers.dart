import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stub providers for features not yet implemented in PostgreSQL backend
/// 
/// These providers replace Firebase stream providers with empty streams/data
/// TODO: Implement with backend API calls

// Stub class for QuerySnapshot-like data
class _StubQuerySnapshot {
  final List<dynamic> docs = [];
}

// Stub class for DocumentSnapshot-like data
class _StubDocumentSnapshot {
  Map<String, dynamic>? data() => null;
}

/// Current user data provider - STUB (replaced currentUserDataProvider)
final currentUserDataProvider = FutureProvider<_StubDocumentSnapshot?>((ref) async {
  // TODO: Fetch from backend API
  return _StubDocumentSnapshot();
});

/// Procedures stream provider - STUB
final proceduresStreamProvider = StreamProvider<_StubQuerySnapshot>((ref) {
  // TODO: Implement with backend /api/procedures endpoint
  return Stream.value(_StubQuerySnapshot());
});

/// Stock items stream provider - STUB
final stockItemsStreamProvider = StreamProvider<_StubQuerySnapshot>((ref) {
  // TODO: Implement with backend /api/stock endpoint
  return Stream.value(_StubQuerySnapshot());
});

/// Users stream provider - STUB
final usersStreamProvider = StreamProvider<_StubQuerySnapshot>((ref) {
  // TODO: Implement with backend /api/users endpoint
  return Stream.value(_StubQuerySnapshot());
});

/// Upcoming appointments provider - STUB
final upcomingAppointmentsStreamProvider = StreamProvider<_StubQuerySnapshot>((ref) {
  // TODO: Implement with backend API
  return Stream.value(_StubQuerySnapshot());
});

/// Low stock items provider - STUB
final lowStockItemsStreamProvider = StreamProvider<_StubQuerySnapshot>((ref) {
  // TODO: Implement with backend API
  return Stream.value(_StubQuerySnapshot());
});

/// Clinic service provider - STUB
final clinicServiceProvider = Provider((ref) {
  // TODO: Implement ClinicService for backend API
  return _StubService();
});

/// Admin stats provider - STUB
final adminStatsProvider = Provider<Map<String, dynamic>>((ref) {
  // TODO: Implement admin stats from backend
  return {};
});

/// Clinic list provider - STUB
final clinicListProvider = Provider<List<dynamic>>((ref) {
  // TODO: Implement with backend /api/clinics endpoint
  return [];
});

/// User list provider - STUB
final userListProvider = Provider<List<dynamic>>((ref) {
  // TODO: Implement with backend /api/users endpoint
  return [];
});

class _StubService {
  Future<void> updateClinic(String id, Map<String, dynamic> data) async {
    throw UnimplementedError('Clinic update not yet implemented in backend');
  }
  
  Future<Map<String, dynamic>> getClinic(String id) async {
    throw UnimplementedError('Get clinic not yet implemented in backend');
  }
}

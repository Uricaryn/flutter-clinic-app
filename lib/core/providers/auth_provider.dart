import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clinic_app/core/services/auth_service.dart';
import 'package:clinic_app/core/enums/user_role.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Add a delay to ensure splash screen is shown and animations complete
final authStateProvider = StreamProvider<User?>((ref) async* {
  // Add initial delay to show splash screen and complete animations
  await Future.delayed(const Duration(seconds: 2));

  // Get initial auth state
  final initialUser = FirebaseAuth.instance.currentUser;
  if (initialUser != null) {
    // Check if session is expired
    final authService = ref.read(authServiceProvider);
    if (authService.isSessionExpired()) {
      await authService.signOut();
      yield null;
    } else {
      yield initialUser;
    }
  } else {
    yield null;
  }

  // Listen to subsequent changes
  yield* FirebaseAuth.instance.authStateChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

// Loading state provider for auth operations
final authLoadingProvider = StateProvider<bool>((ref) => false);

// Error state provider for auth operations
final authErrorProvider = StateProvider<String?>((ref) => null);

// Email verification state provider
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.emailVerified ?? false;
});

final userRoleProvider = StreamProvider<UserRole?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    final role = doc.data()?['role'] as String?;
    return role != null ? UserRole.fromString(role) : null;
  });
});

final canAccessScreenProvider =
    Provider.family<bool, String>((ref, screenName) {
  final roleAsync = ref.watch(userRoleProvider);
  return roleAsync.when(
    data: (role) {
      if (role == null) return false;

      switch (screenName) {
        case '/clinic-manager-panel':
          return role.isClinicAdmin;
        case '/appointments':
          return role.canViewAppointments;
        case '/patients':
          return role.isClinicAdmin || role.isOperator;
        case '/doctors':
          return role.isClinicAdmin;
        case '/operators':
          return role.isClinicAdmin;
        case '/profile':
          return true; // Herkes kendi profilini görebilir
        default:
          return false;
      }
    },
    loading: () => false,
    error: (_, __) => false,
  );
});

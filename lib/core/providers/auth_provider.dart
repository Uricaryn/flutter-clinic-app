import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/services/postgresql_auth_service.dart';

/// PostgreSQL Auth Service Provider
final authServiceProvider = Provider<PostgresqlAuthService>((ref) {
  return PostgresqlAuthService();
});

/// Auth State Provider - Watches user authentication state
final authStateProvider = StreamProvider<PostgresqlUser?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.userChanges();
});

/// Current User Provider - Returns current authenticated user
final currentUserProvider = Provider<PostgresqlUser?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    data: (user) => user,
    orElse: () => null,
  );
});

/// Auth Loading Provider - Checks if auth is loading
final authLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.isLoading;
});

/// Auth Error Provider - Returns auth error if any
final authErrorProvider = Provider<Object?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    error: (error, stack) => error,
    orElse: () => null,
  );
});

/// Email Verified Provider - Checks if current user's email is verified
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.emailVerified ?? false;
});

/// User Role Provider - Returns current user's role
final userRoleProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role;
});

/// Role-based access provider
final canAccessScreenProvider =
    Provider.family<bool, String>((ref, requiredRole) {
  final userRole = ref.watch(userRoleProvider);
  if (userRole == null) return false;

  // Define role hierarchy (higher number = more access)
  final roleHierarchy = {
    'clinic_admin': 4,
    'clinic_manager': 3,
    'operator': 2,
    'user': 1,
  };

  final currentRoleLevel = roleHierarchy[userRole] ?? 0;
  final requiredRoleLevel = roleHierarchy[requiredRole] ?? 999;

  return currentRoleLevel >= requiredRoleLevel;
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:clinic_app/core/config/app_mode.dart';
import 'package:clinic_app/core/services/auth_service.dart';
import 'package:clinic_app/core/services/postgresql_auth_service.dart';
import 'package:clinic_app/core/services/base_auth_service.dart';
import 'package:clinic_app/core/enums/user_role.dart';
import 'package:clinic_app/core/services/database_service.dart';
import 'package:clinic_app/core/providers/database_provider.dart';

/// Unified user class for both Firebase and PostgreSQL
class UnifiedUser {
  final String id;
  final String? email;
  final String? displayName;
  final bool emailVerified;
  final String? clinicId;
  final String? role;

  UnifiedUser({
    required this.id,
    this.email,
    this.displayName,
    this.emailVerified = false,
    this.clinicId,
    this.role,
  });

  factory UnifiedUser.fromFirebase(
      firebase.User user, Map<String, dynamic>? userData) {
    return UnifiedUser(
      id: user.uid,
      email: user.email,
      displayName: user.displayName,
      emailVerified: user.emailVerified,
      clinicId: userData?['clinicId'] as String?,
      role: userData?['role'] as String?,
    );
  }

  factory UnifiedUser.fromPostgresql(PostgresqlUser user) {
    return UnifiedUser(
      id: user.id,
      email: user.email,
      displayName: user.fullName,
      emailVerified: user.emailVerified,
      clinicId: user.clinicId,
      role: user.role,
    );
  }
}

/// Dual-mode auth service provider
final dualAuthServiceProvider = Provider<BaseAuthService>((ref) {
  if (AppMode.isFirebase) {
    return AuthService(); // Firebase auth service
  } else {
    return PostgresqlAuthService(); // PostgreSQL auth service
  }
});

/// Unified auth state provider that works with both backends
final unifiedAuthStateProvider = StreamProvider<UnifiedUser?>((ref) async* {
  if (AppMode.isFirebase) {
    // Firebase mode
    await Future.delayed(const Duration(seconds: 2)); // Splash screen delay

    final initialUser = firebase.FirebaseAuth.instance.currentUser;
    if (initialUser != null) {
      final db = ref.read(databaseProvider);
      final userData = await db.getUserData(initialUser.uid);
      yield UnifiedUser.fromFirebase(initialUser, userData);
    } else {
      yield null;
    }

    await for (final user
        in firebase.FirebaseAuth.instance.authStateChanges()) {
      if (user != null) {
        final db = ref.read(databaseProvider);
        final userData = await db.getUserData(user.uid);
        yield UnifiedUser.fromFirebase(user, userData);
      } else {
        yield null;
      }
    }
  } else {
    // PostgreSQL mode
    await Future.delayed(const Duration(seconds: 2)); // Splash screen delay

    final authService = PostgresqlAuthService();
    await authService.initialize();

    final initialUser = authService.currentUser;
    if (initialUser != null) {
      yield UnifiedUser.fromPostgresql(initialUser);
    } else {
      yield null;
    }

    await for (final user in authService.authStateChanges) {
      if (user != null) {
        yield UnifiedUser.fromPostgresql(user);
      } else {
        yield null;
      }
    }
  }
});

/// Current user provider
final currentUnifiedUserProvider = Provider<UnifiedUser?>((ref) {
  final authState = ref.watch(unifiedAuthStateProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

/// Loading state provider for auth operations
final authLoadingProvider = StateProvider<bool>((ref) => false);

/// Error state provider for auth operations
final authErrorProvider = StateProvider<String?>((ref) => null);

/// Email verification state provider
final isEmailVerifiedProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUnifiedUserProvider);
  return user?.emailVerified ?? false;
});

/// User role provider
final userRoleProvider = Provider<UserRole?>((ref) {
  final user = ref.watch(currentUnifiedUserProvider);
  if (user == null || user.role == null) return null;
  return UserRole.fromString(user.role!);
});

/// Screen access provider
final canAccessScreenProvider =
    Provider.family<bool, String>((ref, screenName) {
  final role = ref.watch(userRoleProvider);
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
      return true; // Everyone can view their own profile
    default:
      return false;
  }
});

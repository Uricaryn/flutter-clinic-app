import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:clinic_app/core/services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authServiceProvider).currentUser;
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
 
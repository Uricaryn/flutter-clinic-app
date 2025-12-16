/// Legacy auth_provider.dart - now wraps dual_auth_provider for backward compatibility
///
/// This file maintains backward compatibility with existing code that imports auth_provider.
/// All providers now work in dual-mode (Firebase or PostgreSQL) based on AppMode.
///
/// New code should import dual_auth_provider.dart directly for clarity.

// Re-export everything from dual_auth_provider
export 'package:clinic_app/core/providers/dual_auth_provider.dart'
    show
        UnifiedUser,
        dualAuthServiceProvider,
        unifiedAuthStateProvider,
        currentUnifiedUserProvider,
        authLoadingProvider,
        authErrorProvider,
        isEmailVerifiedProvider,
        userRoleProvider,
        canAccessScreenProvider;

// Create backward-compatible aliases
import 'package:clinic_app/core/providers/dual_auth_provider.dart';

/// Auth service that works with both Firebase and PostgreSQL
///
/// Alias for dualAuthServiceProvider
final authServiceProvider = dualAuthServiceProvider;

/// Auth state stream that works with both backends
///
/// Returns UnifiedUser which works with both Firebase.User and PostgresqlUser
/// Alias for unifiedAuthStateProvider
final authStateProvider = unifiedAuthStateProvider;

/// Current user provider
///
/// Returns UnifiedUser? (works with both backends)
/// Alias for currentUnifiedUserProvider
final currentUserProvider = currentUnifiedUserProvider;

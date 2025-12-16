/// Legacy auth_provider.dart - now wraps dual_auth_provider for backward compatibility
///
/// This file maintains backward compatibility with existing code that imports auth_provider.
/// All providers now work in dual-mode (Firebase or PostgreSQL) based on AppMode.
///
/// New code should import dual_auth_provider.dart directly for clarity.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/providers/dual_auth_provider.dart';

// Re-export all dual-mode providers with legacy names for backward compatibility

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

/// Loading state for auth operations
/// Already defined in dual_auth_provider
// (Re-exported from dual_auth_provider)

/// Error state for auth operations  
/// Already defined in dual_auth_provider
// (Re-exported from dual_auth_provider)

/// Email verification state
/// Already defined in dual_auth_provider
// (Re-exported from dual_auth_provider)

/// User role provider
/// Already defined in dual_auth_provider
// (Re-exported from dual_auth_provider)

/// Screen access permission provider
/// Already defined in dual_auth_provider
// (Re-exported from dual_auth_provider)

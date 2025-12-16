import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';

class RoleBasedAccess extends ConsumerWidget {
  final String screenName;
  final Widget child;
  final Widget? fallback;

  const RoleBasedAccess({
    super.key,
    required this.screenName,
    required this.child,
    this.fallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAccess = ref.watch(canAccessScreenProvider(screenName));
    final role = ref.watch(userRoleProvider);

    // If no role, show loading or error
    if (role == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Check access permission
    if (!canAccess) {
      return fallback ??
          const Center(
            child: Text('Bu sayfaya erişim yetkiniz bulunmuyor.'),
          );
    }

    return child;
  }
}

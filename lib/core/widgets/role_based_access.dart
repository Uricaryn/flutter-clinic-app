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
    final roleAsync = ref.watch(userRoleProvider);

    return roleAsync.when(
      data: (role) {
        if (!canAccess) {
          return fallback ??
              const Center(
                child: Text('Bu sayfaya erişim yetkiniz bulunmuyor.'),
              );
        }
        return child;
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(
        child: Text('Bir hata oluştu. Lütfen tekrar deneyin.'),
      ),
    );
  }
}

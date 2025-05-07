import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:clinic_app/features/profile/presentation/screens/change_password_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final userData = ref.watch(currentUserDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  Center(
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                      style: theme.textTheme.headlineLarge?.copyWith(
                                    color: theme.colorScheme.onPrimary,
                                  ),
                                ),
                  ).animate().fadeIn().scale(),
                        const SizedBox(height: 16),
                        Text(
                    userData.when(
                      data: (data) => data?['fullName'] ?? 'User',
                      loading: () => 'Loading...',
                      error: (_, __) => 'Error loading name',
                    ),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                  Text(
                    user?.email ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                          ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Account Settings
                  Text(
                    'Account Settings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                  const SizedBox(height: 16),
                  Card(
                    child: Column(
                      children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Edit Profile'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Change Email'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // TODO: Navigate to change email
                    },
                  ),
                  const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.lock_outline),
                          title: const Text('Change Password'),
                          trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ).animate().fadeIn().slideX(begin: 0.2, end: 0),
            const SizedBox(height: 24),
            // Preferences
            Text(
              'Preferences',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                        ),
            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                        ListTile(
                          leading: const Icon(Icons.notifications_outlined),
                          title: const Text('Notifications'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Navigate to notifications settings
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.language_outlined),
                          title: const Text('Language'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Navigate to language settings
                          },
                        ),
                      ],
                    ),
            ).animate().fadeIn().slideX(begin: 0.2, end: 0),
                  const SizedBox(height: 32),
                  // Sign Out Button
            CustomButton(
                      text: 'Sign Out',
              onPressed: () async {
                await ref.read(authServiceProvider).signOut();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              },
                      variant: ButtonVariant.secondary,
            ).animate().fadeIn().slideY(begin: 0.2, end: 0),
              ],
            ),
      ),
    );
  }
}

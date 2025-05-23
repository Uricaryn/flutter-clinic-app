import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:clinic_app/core/providers/firestore_provider.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:clinic_app/features/profile/presentation/screens/change_password_screen.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:clinic_app/core/providers/locale_provider.dart';
import 'package:clinic_app/shared/widgets/auth_background.dart';
import 'package:clinic_app/core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  bool _useSystemTheme = true;
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme_mode');
    if (themeIndex != null) {
      setState(() {
        _useSystemTheme = ThemeMode.values[themeIndex] == ThemeMode.system;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadThemePreference();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);
    try {
      final snapshot = await ref.read(currentUserDataProvider.future);
      if (mounted) {
        setState(() {
          _userData = snapshot?.data() as Map<String, dynamic>?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: AuthBackground(
        showMedicalIcons: false,
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.profile,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () {
                        // TODO: Navigate to settings
                      },
                    ),
                  ],
                ),
              ),
              // Main Content
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadUserData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Profile Header
                      Center(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: theme.colorScheme.primary,
                              child: Text(
                                user?.email?.substring(0, 1).toUpperCase() ??
                                    'U',
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _userData?['fullName'] ?? l10n.user,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user?.email ?? '',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurface
                                    .withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Account Settings
                      Text(
                        l10n.accountSettings,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: Text(l10n.editProfile),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const EditProfileScreen(),
                                  ),
                                );
                              },
                            ),
                            const Divider(height: 1),
                            CheckboxListTile(
                              value: _useSystemTheme,
                              onChanged: (bool? value) {
                                if (value != null) {
                                  setState(() => _useSystemTheme = value);
                                  ref.read(themeProvider.notifier).setTheme(
                                        value
                                            ? ThemeMode.system
                                            : ThemeMode.light,
                                      );
                                }
                              },
                              title: Text(l10n.useSystemTheme),
                              secondary: const Icon(Icons.brightness_auto),
                            ),
                            if (!_useSystemTheme) ...[
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.brightness_6),
                                title: Text(l10n.theme),
                                trailing: Switch(
                                  value: ref.watch(themeProvider) ==
                                      ThemeMode.dark,
                                  onChanged: (bool value) {
                                    ref.read(themeProvider.notifier).setTheme(
                                          value
                                              ? ThemeMode.dark
                                              : ThemeMode.light,
                                        );
                                  },
                                ),
                              ),
                            ],
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.email_outlined),
                              title: Text(l10n.changeEmail),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // TODO: Navigate to change email
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.lock_outline),
                              title: Text(l10n.changePassword),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ChangePasswordScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Preferences
                      Text(
                        l10n.preferences,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.notifications_outlined),
                              title: Text(l10n.notifications),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                // TODO: Navigate to notifications settings
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.language_outlined),
                              title: Text(l10n.language),
                              trailing: Text(
                                ref
                                    .watch(localeProvider)
                                    .languageCode
                                    .toUpperCase(),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              onTap: () {
                                ref
                                    .read(localeProvider.notifier)
                                    .toggleLocale();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Sign Out Button
                      CustomButton(
                        text: l10n.signOut,
                        onPressed: () async {
                          try {
                            await ref.read(authServiceProvider).signOut();
                            // Reset loading state
                            ref.read(authLoadingProvider.notifier).state =
                                false;
                            if (context.mounted) {
                              Navigator.of(context)
                                  .pushReplacementNamed('/login');
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(e.toString()),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          }
                        },
                        variant: ButtonVariant.secondary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

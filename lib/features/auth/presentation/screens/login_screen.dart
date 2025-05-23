import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:clinic_app/core/providers/locale_provider.dart';
import 'package:clinic_app/shared/widgets/custom_text_field.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/features/auth/presentation/screens/register_screen.dart';
import 'package:clinic_app/features/home/presentation/screens/home_screen.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:clinic_app/shared/widgets/auth_background.dart';
import 'package:clinic_app/core/services/navigation_service.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    ref.read(authLoadingProvider.notifier).state = true;
    ref.read(authErrorProvider.notifier).state = null;

    try {
      await ref.read(authServiceProvider).signInWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
          );

      if (!mounted) return;

      // Check if email is verified
      final user = ref.read(currentUserProvider);
      if (user != null && !user.emailVerified) {
        // Show email verification dialog
        _showEmailVerificationDialog();
        return;
      }

      // Navigate to home screen
      await NavigationService.navigateToNamedAndClearStack('/home');
    } catch (e) {
      if (!mounted) return;
      ref.read(authErrorProvider.notifier).state = e.toString();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }

  void _showEmailVerificationDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.emailVerificationRequired),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.pleaseVerifyEmail),
            const SizedBox(height: 16),
            CustomButton(
              text: l10n.resendVerificationEmail,
              onPressed: () async {
                try {
                  await ref.read(authServiceProvider).verifyEmail();
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.verificationEmailSent),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authServiceProvider).signOut();
            },
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);
    final error = ref.watch(authErrorProvider);
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    // Responsive sizes
    final padding = size.width * 0.06; // 6% of screen width
    final spacing = size.height * 0.02; // 2% of screen height
    final logoSize = size.width * 0.25; // 25% of screen width
    final titleSize = size.height * 0.04; // 4% of screen height
    final subtitleSize = size.height * 0.02; // 2% of screen height

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Language Switcher
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.language),
                      onPressed: () {
                        ref.read(localeProvider.notifier).toggleLocale();
                      },
                    ),
                  ),
                  SizedBox(height: spacing * 2),
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      'assets/images/ordana_login_logo.png',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain,
                    ).animate().fadeIn().scale(),
                  ),
                  SizedBox(height: spacing),
                  Text(
                    l10n.welcomeBack,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: titleSize,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().moveY(begin: 10, end: 0),
                  SizedBox(height: spacing * 0.5),
                  Text(
                    l10n.signInToContinue,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: subtitleSize,
                        ),
                    textAlign: TextAlign.center,
                  ).animate().fadeIn().moveY(begin: 10, end: 0),
                  SizedBox(height: spacing * 2),
                  CustomTextField(
                    controller: _emailController,
                    label: l10n.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icon(Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterEmail;
                      }
                      if (!value.contains('@')) {
                        return l10n.pleaseEnterValidEmail;
                      }
                      return null;
                    },
                  ).animate().fadeIn().moveX(begin: -10, end: 0),
                  SizedBox(height: spacing),
                  CustomTextField(
                    controller: _passwordController,
                    label: l10n.password,
                    obscureText: _obscurePassword,
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterPassword;
                      }
                      if (value.length < 6) {
                        return l10n.passwordMustBeAtLeast6Characters;
                      }
                      return null;
                    },
                  ).animate().fadeIn().moveX(begin: 10, end: 0),
                  if (error != null) ...[
                    SizedBox(height: spacing),
                    Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: subtitleSize * 0.9,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(),
                  ],
                  SizedBox(height: spacing),
                  CustomButton(
                    text: l10n.signIn,
                    onPressed: _handleLogin,
                    isLoading: isLoading,
                  ).animate().fadeIn().moveY(begin: 10, end: 0),
                  SizedBox(height: spacing * 0.5),
                  TextButton(
                    onPressed: () {
                      ref.read(authServiceProvider).sendPasswordResetEmail(
                            _emailController.text.trim(),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.passwordResetEmailSent),
                        ),
                      );
                    },
                    child: Text(
                      l10n.forgotPassword,
                      style: TextStyle(fontSize: subtitleSize * 0.9),
                    ),
                  ).animate().fadeIn(),
                  SizedBox(height: spacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.dontHaveAccount,
                        style: TextStyle(fontSize: subtitleSize * 0.9),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          l10n.signUp,
                          style: TextStyle(fontSize: subtitleSize * 0.9),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

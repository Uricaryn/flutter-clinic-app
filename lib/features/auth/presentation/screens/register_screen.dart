import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/shared/widgets/custom_text_field.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:clinic_app/features/auth/presentation/screens/email_verification_screen.dart';
import 'package:clinic_app/l10n/app_localizations.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Set loading state
    ref.read(authLoadingProvider.notifier).state = true;
    // Clear any previous errors
    ref.read(authErrorProvider.notifier).state = null;

    try {
      await ref.read(authServiceProvider).registerWithEmailAndPassword(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
            'patient', // Default role
          );

      if (!mounted) return;

      // Navigate to email verification screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) => const EmailVerificationScreen()),
      );
    } catch (e) {
      if (!mounted) return;
      ref.read(authErrorProvider.notifier).state = e.toString();
    } finally {
      if (mounted) {
        ref.read(authLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLoading = ref.watch(authLoadingProvider);
    final error = ref.watch(authErrorProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createAccount),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Text
                  Text(
                    l10n.joinUs,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 8),
                  Text(
                    l10n.createAccountToGetStarted,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 32),
                  // Name Field
                  CustomTextField(
                    controller: _nameController,
                    label: l10n.fullName,
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterName;
                      }
                      return null;
                    },
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  // Email Field
                  CustomTextField(
                    controller: _emailController,
                    label: l10n.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterEmail;
                      }
                      if (!value.contains('@')) {
                        return l10n.pleaseEnterValidEmail;
                      }
                      return null;
                    },
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 16),
                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    label: l10n.password,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline),
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
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),
                  if (error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      error,
                      style: TextStyle(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(),
                  ],
                  const SizedBox(height: 32),
                  // Register Button
                  CustomButton(
                    text: l10n.createAccount,
                    onPressed: _handleRegister,
                    isLoading: isLoading,
                    width: size.width,
                  ),
                  const SizedBox(height: 24),
                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        l10n.alreadyHaveAccount,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          l10n.signIn,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/shared/widgets/custom_text_field.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:clinic_app/features/auth/presentation/screens/registration_success_screen.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'package:clinic_app/core/services/logger_service.dart';
import 'package:clinic_app/core/services/navigation_service.dart';
import 'package:clinic_app/core/utils/validation_utils.dart';
import 'package:clinic_app/core/enums/user_role.dart';
import 'package:clinic_app/shared/widgets/auth_background.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _logger = LoggerService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  UserRole? _selectedRole;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _logger.info('RegisterScreen initialized');
    _selectedRole = UserRole.clinicAdmin; // Sadece klinik yöneticisi kaydı
  }

  @override
  void dispose() {
    _logger.info('RegisterScreen disposed');
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    _logger.info('_handleRegister started');

    if (!_formKey.currentState!.validate()) {
      _logger.info('Form validation failed');
      return;
    }
    if (_isLoading) {
      _logger.info('Registration already in progress');
      return;
    }

    setState(() => _isLoading = true);
    _logger.info('Loading state set to true');

    try {
      _logger.info('Starting registration process...');

      final credential =
          await ref.read(authServiceProvider).registerWithEmailAndPassword(
                _emailController.text.trim(),
                _passwordController.text,
                _nameController.text.trim(),
                UserRole.clinicAdmin.value,
              );

      _logger.info(
          'Registration successful, user created: \\${credential.user?.uid}');

      if (!mounted) {
        _logger.warning('Widget not mounted after registration');
        return;
      }

      _logger.info('Navigating to registration success screen...');

      // Direct navigation after successful registration
      await NavigationService.navigateToSlideUp(
        const RegistrationSuccessScreen(),
        replace: true,
      );
    } catch (e) {
      _logger.error('Registration failed: $e');
      if (!mounted) {
        _logger.warning('Widget not mounted after error');
        return;
      }

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'OK',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.info('RegisterScreen build method called');
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async {
        _logger.info('Back button pressed, loading state: $_isLoading');
        return !_isLoading;
      },
      child: Scaffold(
        body: AuthBackground(
          child: SafeArea(
            child: Column(
              children: [
                // Custom App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      if (!_isLoading)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      Expanded(
                        child: Text(
                          l10n.createAccount,
                          style: theme.textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      // Placeholder for symmetry
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.registerTitle,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.registerSubtitle,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 32),
                          CustomTextField(
                            controller: _nameController,
                            label: l10n.fullName,
                            hint: l10n.nameHint,
                            prefixIcon: const Icon(Icons.person_outline),
                            validator: ValidationUtils.validateName,
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _emailController,
                            label: l10n.email,
                            hint: l10n.emailHint,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email_outlined),
                            validator: ValidationUtils.validateEmail,
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _passwordController,
                            label: l10n.password,
                            hint: l10n.passwordHint,
                            obscureText: _obscurePassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() =>
                                          _obscurePassword = !_obscurePassword);
                                    },
                            ),
                            validator: ValidationUtils.validatePassword,
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            controller: _confirmPasswordController,
                            label: l10n.confirmPassword,
                            hint: l10n.confirmPasswordHint,
                            obscureText: _obscurePassword,
                            prefixIcon: const Icon(Icons.lock_outline),
                            validator: (value) =>
                                ValidationUtils.validatePasswordConfirmation(
                              value,
                              _passwordController.text,
                            ),
                            enabled: !_isLoading,
                          ),
                          const SizedBox(height: 32),
                          CustomButton(
                            text: l10n.registerButton,
                            onPressed: _isLoading ? null : _handleRegister,
                            isLoading: _isLoading,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.alreadyHaveAccountText,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7),
                                ),
                              ),
                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        _logger.info('Sign in button pressed');
                                        NavigationService.goBack();
                                      },
                                child: Text(
                                  l10n.loginLink,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

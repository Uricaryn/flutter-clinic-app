import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:clinic_app/core/config/app_mode.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/shared/widgets/custom_text_field.dart';
import 'package:clinic_app/core/services/auth_service.dart';
import 'package:clinic_app/core/services/postgresql_auth_service.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) throw Exception('User not found');

      if (AppMode.isFirebase) {
        // Firebase mode - use native Firebase methods
        final firebaseUser = firebase.FirebaseAuth.instance.currentUser;
        if (firebaseUser == null) throw Exception('Firebase user not found');

        // Reauthenticate user
        final credential = firebase.EmailAuthProvider.credential(
          email: user.email!,
          password: _currentPasswordController.text,
        );
        await firebaseUser.reauthenticateWithCredential(credential);

        // Change password
        await firebaseUser.updatePassword(_newPasswordController.text);
      } else {
        // PostgreSQL mode - use auth service changePassword method
        final authService = ref.read(authServiceProvider) as PostgresqlAuthService;
        await authService.changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _currentPasswordController,
                label: 'Current Password',
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: _obscureCurrentPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _newPasswordController,
                label: 'New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: _obscureNewPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                prefixIcon: const Icon(Icons.lock_outline),
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Change Password',
                onPressed: _isLoading ? null : _changePassword,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 
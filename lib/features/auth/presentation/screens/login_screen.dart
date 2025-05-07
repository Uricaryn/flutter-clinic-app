import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:clinic_app/shared/widgets/custom_text_field.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/features/auth/presentation/screens/register_screen.dart';
import 'package:clinic_app/features/home/presentation/screens/home_screen.dart';

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

    // Set loading state
    ref.read(authLoadingProvider.notifier).state = true;
    // Clear any previous errors
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
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
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

  void _showEmailVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Email Verification Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please verify your email address before logging in. '
              'Check your inbox for the verification link.',
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Resend Verification Email',
              onPressed: () async {
                try {
                  await ref.read(authServiceProvider).verifyEmail();
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Verification email sent. Please check your inbox.'),
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
            child: const Text('OK'),
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

    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue.shade50,
                  Colors.teal.shade50,
                ],
              ),
            ),
          ),
          // Oval shape divider
          Positioned(
            top: size.height * 0.3,
            left: -size.width * 0.2,
            right: -size.width * 0.2,
            child: Container(
              height: size.height * 0.7,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(size.width * 0.5),
                  topRight: Radius.circular(size.width * 0.5),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
            ),
          ),
          // Decorative medical icons
          Positioned(
            top: size.height * 0.05,
            left: size.width * 0.1,
            child: Icon(
              Icons.medical_services_outlined,
              size: 40,
              color: Colors.blue.shade200,
            ).animate().fadeIn().scale(),
          ),
          Positioned(
            top: size.height * 0.15,
            right: size.width * 0.1,
            child: Icon(
              Icons.favorite_outline,
              size: 40,
              color: Colors.teal.shade200,
            ).animate().fadeIn().scale(),
          ),
          // Login form
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    Icon(
                      Icons.local_hospital,
                      size: 64,
                      color: Theme.of(context).primaryColor,
                    ).animate().fadeIn().scale(),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                    ).animate().fadeIn().moveY(begin: 10, end: 0),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ).animate().fadeIn().moveY(begin: 10, end: 0),
                    const SizedBox(height: 48),
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icon(Icons.email_outlined),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ).animate().fadeIn().moveX(begin: -10, end: 0),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
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
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ).animate().fadeIn().moveX(begin: 10, end: 0),
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(),
                    ],
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Sign In',
                      onPressed: _handleLogin,
                      isLoading: isLoading,
                    ).animate().fadeIn().moveY(begin: 10, end: 0),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                        ref.read(authServiceProvider).sendPasswordResetEmail(
                              _emailController.text.trim(),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password reset email sent'),
                          ),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ).animate().fadeIn(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text('Sign Up'),
                        ),
                      ],
                    ).animate().fadeIn(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

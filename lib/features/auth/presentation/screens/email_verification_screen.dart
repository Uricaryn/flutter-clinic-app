import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinic_app/core/providers/auth_provider.dart';
import 'package:clinic_app/features/home/presentation/screens/home_screen.dart';
import 'package:clinic_app/shared/widgets/custom_button.dart';
import 'package:clinic_app/core/services/logger_service.dart';
import 'package:clinic_app/l10n/app_localizations.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  final _logger = LoggerService();
  bool _isResending = false;
  bool _isChecking = false;
  Timer? _autoCheckTimer;

  @override
  void initState() {
    super.initState();
    // Start auto-checking every 5 seconds
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isChecking) {
        _checkVerificationStatus();
      }
    });
  }

  @override
  void dispose() {
    _autoCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _resendVerificationEmail() async {
    setState(() => _isResending = true);
    try {
      _logger.info('Attempting to resend verification email');
      await ref.read(authServiceProvider).verifyEmail();
      if (!mounted) return;
      _logger.info('Verification email resent successfully');

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.verificationEmailSent),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      _logger.error(
          'Failed to resend verification email', e, StackTrace.current);
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.ok,
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() => _isChecking = true);
    try {
      _logger.info('Checking email verification status');
      await ref.read(authServiceProvider).reloadUser();

      if (!mounted) return;

      final user = ref.read(currentUserProvider);
      final l10n = AppLocalizations.of(context)!;

      if (user?.emailVerified ?? false) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'emailVerified': true});
        _logger.info('Email verified successfully');
        _autoCheckTimer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.emailVerifiedSuccess),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        _logger.info('Email not verified yet');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.emailNotVerifiedYet),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _logger.error(
          'Error checking verification status', e, StackTrace.current);
      if (!mounted) return;

      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Theme.of(context).colorScheme.error,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: l10n.ok,
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final isVerified = ref.watch(isEmailVerifiedProvider);
    final l10n = AppLocalizations.of(context)!;

    // If email is verified, navigate to home screen
    if (isVerified) {
      _logger.info('Email verified, navigating to home screen');
      _autoCheckTimer?.cancel();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.emailVerificationRequired),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.mark_email_unread_outlined,
                size: 80,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.emailVerificationRequired,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${l10n.verificationEmailSent}\n${user?.email}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.pleaseVerifyEmail,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: l10n.resendVerificationEmail,
                      onPressed: _resendVerificationEmail,
                      isLoading: _isResending,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: l10n.checkStatus,
                      onPressed: _checkVerificationStatus,
                      isLoading: _isChecking,
                      variant: ButtonVariant.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _logger.info('User returning to login screen');
                  _autoCheckTimer?.cancel();
                  ref.read(authServiceProvider).signOut();
                  Navigator.of(context).pop();
                },
                child: Text(l10n.backToLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

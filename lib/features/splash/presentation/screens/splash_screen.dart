import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/features/auth/presentation/screens/login_screen.dart';
import 'package:clinic_app/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _navigateToLogin();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _navigateToLogin() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E90E8), // sol alt açık mavi
              Color(0xFF0072CE), // sağ üst koyu mavi
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with simple fade-in animation
              Image.asset(
                'assets/images/ordana_logo.png',
                width: 200,
                height: 200,
              ).animate().fadeIn(duration: const Duration(milliseconds: 800)),
              const SizedBox(height: 32),
              // App Name with slide and fade animation
              Text(
                'Ordana',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 48,
                    ),
              )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 400))
                  .moveY(begin: 20, end: 0)
                  .then()
                  .shimmer(
                    duration: const Duration(seconds: 2),
                    color: Colors.white.withOpacity(0.8),
                  ),
              const SizedBox(height: 48),
              // Klinik yönetimi sloganı (daha küçük)
              Text(
                AppLocalizations.of(context)!.splashSlogan,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                    ),
              )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 800))
                  .moveY(begin: 20, end: 0)
                  .then()
                  .shimmer(
                    duration: const Duration(seconds: 2),
                    color: Colors.white.withOpacity(0.8),
                  ),
              const SizedBox(height: 48),
              // Loading indicator with custom animation
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _controller.value * 2 * 3.14159,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8),
                      ),
                      strokeWidth: 3,
                    ),
                  );
                },
              )
                  .animate()
                  .fadeIn(delay: const Duration(milliseconds: 1200))
                  .scale(
                    begin: const Offset(0.8, 0.8),
                    end: const Offset(1.0, 1.0),
                    duration: const Duration(milliseconds: 800),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

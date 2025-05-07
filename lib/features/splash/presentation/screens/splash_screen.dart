import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:clinic_app/features/auth/presentation/screens/login_screen.dart';

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
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with pulse animation
            Icon(
              Icons.local_hospital,
              size: 100,
              color: Colors.white,
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 800))
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: const Duration(milliseconds: 800),
                )
                .then()
                .shimmer(
                  duration: const Duration(seconds: 2),
                  color: Colors.white.withOpacity(0.8),
                )
                .then()
                .scale(
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.1, 1.1),
                  duration: const Duration(seconds: 1),
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 24),
            // App Name with slide and fade animation
            Text(
              'Clinic App',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
            const SizedBox(height: 16),
            // Tagline with slide and fade animation
            Text(
              'Your Health, Our Priority',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
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
            ).animate().fadeIn(delay: const Duration(milliseconds: 1200)).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1.0, 1.0),
                  duration: const Duration(milliseconds: 800),
                ),
          ],
        ),
      ),
    );
  }
}
 
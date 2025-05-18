import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final screenHeight = size.height - padding.top - padding.bottom;

    // Responsive sizes
    final logoSize = screenHeight * 0.25; // 25% of screen height
    final titleSize = screenHeight * 0.06; // 6% of screen height
    final sloganSize = screenHeight * 0.025; // 2.5% of screen height
    final spacing = screenHeight * 0.03; // 3% of screen height

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1E90E8),
                Color(0xFF0072CE),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with enhanced animation
                    Image.asset(
                      'assets/images/ordana_logo.png',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain,
                    )
                        .animate()
                        .fadeIn(duration: const Duration(milliseconds: 800))
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1.0, 1.0),
                          duration: const Duration(milliseconds: 600),
                        )
                        .then()
                        .rotate(
                          begin: -0.1,
                          end: 0,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutBack,
                        ),
                    SizedBox(height: spacing),
                    // App Name with slide and fade animation
                    Text(
                      'Ordana',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: titleSize,
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
                    SizedBox(height: spacing * 1.5),
                    // Slogan
                    AnimatedTextKit(
                      animatedTexts: [
                        TypewriterAnimatedText(
                          AppLocalizations.of(context)!.splashSlogan,
                          textStyle:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                    fontSize: sloganSize,
                                  ),
                          textAlign: TextAlign.center,
                          speed: const Duration(milliseconds: 50),
                        ),
                      ],
                      totalRepeatCount: 1,
                      displayFullTextOnTap: true,
                      stopPauseOnTap: true,
                    ),
                    SizedBox(height: spacing * 1.5),
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
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  final bool showMedicalIcons;

  const AuthBackground({
    super.key,
    required this.child,
    this.showMedicalIcons = true,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Gradient Background
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.1),
                theme.colorScheme.secondary.withOpacity(0.1),
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
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(size.width * 0.5),
                topRight: Radius.circular(size.width * 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
          ),
        ),
        // Decorative medical icons
        if (showMedicalIcons) ...[
          Positioned(
            top: size.height * 0.05,
            left: size.width * 0.1,
            child: Icon(
              Icons.medical_services_outlined,
              size: 40,
              color: theme.colorScheme.primary.withOpacity(0.5),
            ).animate().fadeIn().scale(),
          ),
          Positioned(
            top: size.height * 0.15,
            right: size.width * 0.1,
            child: Icon(
              Icons.favorite_outline,
              size: 40,
              color: theme.colorScheme.secondary.withOpacity(0.5),
            ).animate().fadeIn().scale(),
          ),
        ],
        // Child widget (actual content)
        child,
      ],
    );
  }
}

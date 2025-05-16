import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum ButtonVariant { primary, secondary, outline }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget buttonChild = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: theme.textTheme.labelLarge?.copyWith(
            color: _getTextColor(theme),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    if (isLoading) {
      buttonChild = SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor(theme)),
        ),
      );
    }

    return IgnorePointer(
      ignoring: isLoading,
      child: SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _getBackgroundColor(theme),
            foregroundColor: _getTextColor(theme),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: variant == ButtonVariant.outline
                  ? BorderSide(color: theme.colorScheme.primary)
                  : BorderSide.none,
            ),
            disabledBackgroundColor:
                _getBackgroundColor(theme).withOpacity(0.7),
            disabledForegroundColor: _getTextColor(theme).withOpacity(0.7),
          ),
          child: buttonChild,
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (variant) {
      case ButtonVariant.primary:
        return theme.colorScheme.primary;
      case ButtonVariant.secondary:
        return theme.colorScheme.secondary;
      case ButtonVariant.outline:
        return Colors.transparent;
    }
  }

  Color _getTextColor(ThemeData theme) {
    switch (variant) {
      case ButtonVariant.primary:
      case ButtonVariant.secondary:
        return theme.colorScheme.onPrimary;
      case ButtonVariant.outline:
        return theme.colorScheme.primary;
    }
  }
}

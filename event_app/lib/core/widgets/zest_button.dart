import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

enum ZestButtonVariant { primary, secondary, ghost, danger }

/// ZestButton — the standard Zest branded button.
/// - primary: coral gradient pill
/// - secondary: charcoal fill pill
/// - ghost: transparent with border
/// - danger: error red pill
class ZestButton extends StatelessWidget {
  const ZestButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ZestButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final ZestButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    Color bg;
    Color fg;
    Gradient? gradient;
    Color? borderColor;

    switch (variant) {
      case ZestButtonVariant.primary:
        bg = AppColors.lime;
        fg = AppColors.ink;
        gradient = AppColors.limeGradient;
      case ZestButtonVariant.secondary:
        bg = AppColors.surfaceCard;
        fg = AppColors.paper;
        borderColor = AppColors.borderDark;
      case ZestButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.paper;
        borderColor = AppColors.borderDark;
      case ZestButtonVariant.danger:
        bg = AppColors.error;
        fg = AppColors.paper;
    }

    final child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: fg, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Bricolage Grotesque',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.01,
                  color: fg,
                ),
              ),
            ],
          );

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
              HapticFeedback.lightImpact();
              onPressed!();
            },
      child: AnimatedOpacity(
        opacity: isDisabled ? 0.55 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: fullWidth ? double.infinity : null,
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: gradient == null ? bg : null,
            gradient: gradient,
            borderRadius: AppRadius.circularPill,
            border: borderColor != null
                ? Border.all(color: borderColor, width: 1.5)
                : null,
          ),
          child: Center(child: child),
        ),
      ),
    );
  }
}

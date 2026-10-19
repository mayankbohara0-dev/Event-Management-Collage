import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ZestButton — Branded button with spring squish feedback
// Spec:
//   • primary: lime fill (#B8FF1A), ink text, height 58, fully rounded, w800 17sp
//   • press squish to 0.95 scale
//   • done state: ink fill with lime text "You're in! ✓"
//   • secondary: surfaceCard fill, paper text
//   • ghost: transparent with border
//   • danger: error red fill
// ─────────────────────────────────────────────────────────────────────────────

enum ZestButtonVariant { primary, secondary, ghost, danger }

class ZestButton extends StatefulWidget {
  const ZestButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ZestButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isDone = false,
    this.doneLabel,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final ZestButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  /// Done state: ink background, lime text. Default label: "You're in! ✓"
  final bool isDone;
  final String? doneLabel;
  final bool fullWidth;

  @override
  State<ZestButton> createState() => _ZestButtonState();
}

class _ZestButtonState extends State<ZestButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = _pressCtrl;
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!_isDisabled) {
      setState(() => _isPressed = true);
      _pressCtrl.animateTo(0.95, curve: Curves.easeOut);
    }
  }

  void _onTapUp(TapUpDetails _) {
    _onRelease();
  }

  void _onTapCancel() {
    _onRelease();
  }

  void _onRelease() {
    if (_isPressed) {
      setState(() => _isPressed = false);
      _pressCtrl.animateTo(1.0, curve: Curves.easeOutBack);
    }
  }

  bool get _isDisabled =>
      (widget.onPressed == null || widget.isLoading) && !widget.isDone;

  @override
  Widget build(BuildContext context) {
    // Done state overrides variant
    Color bg;
    Color fg;
    Gradient? gradient;
    Color? borderColor;

    if (widget.isDone) {
      bg = AppColors.ink;
      fg = AppColors.lime;
    } else {
      switch (widget.variant) {
        case ZestButtonVariant.primary:
          bg = AppColors.lime;
          fg = AppColors.ink;
          gradient = AppColors.limeGradient;
        case ZestButtonVariant.secondary:
          bg = AppColors.ink2;
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
    }

    final effectiveLabel =
        widget.isDone ? (widget.doneLabel ?? "You're in! ✓") : widget.label;
    final effectiveGradient = widget.isDone ? null : gradient;

    final child = widget.isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisSize:
                widget.fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null && !widget.isDone) ...[
                Icon(widget.icon, color: fg, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                effectiveLabel,
                style: TextStyle(
                  fontFamily: 'Bricolage Grotesque',
                  fontSize: 17,        // spec: 17sp
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: fg,
                ),
              ),
            ],
          );

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: (_isDisabled || widget.isDone)
          ? null
          : () {
              HapticFeedback.lightImpact();
              widget.onPressed!();
            },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedOpacity(
          opacity: _isDisabled ? 0.55 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeInOut,
            width: widget.fullWidth ? double.infinity : null,
            height: 58,              // spec: 58px
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: effectiveGradient == null ? bg : null,
              gradient: effectiveGradient,
              borderRadius: AppRadius.circularPill,
              border: borderColor != null
                  ? Border.all(color: borderColor, width: 1.5)
                  : null,
            ),
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/zest_tokens.dart';

enum ZestButtonVariant { primary, secondary, ghost, danger }

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST BUTTON
/// Modern pill button with scale .97 press squish, haptic feedback,
/// three-dot loading bounce, and success check morph.
/// ─────────────────────────────────────────────────────────────────────────────

class ZestButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final ZestButtonVariant variant;
  final bool isLoading;
  final bool isSuccess;
  final bool fullWidth;
  final dynamic icon;
  final dynamic prefixIcon;
  final double height;
  final EdgeInsetsGeometry? padding;

  const ZestButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = ZestButtonVariant.primary,
    this.isLoading = false,
    this.isSuccess = false,
    this.fullWidth = false,
    this.icon,
    this.prefixIcon,
    this.height = 52.0,
    this.padding,
  });


  @override
  State<ZestButton> createState() => _ZestButtonState();
}

class _ZestButtonState extends State<ZestButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null || widget.isLoading || widget.isSuccess) return;
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails _) {
    if (_isPressed) setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (_isPressed) setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null && !widget.isLoading && !widget.isSuccess;

    Color textColor;
    Decoration decoration;

    switch (widget.variant) {
      case ZestButtonVariant.primary:
        textColor = Colors.white;
        decoration = BoxDecoration(
          borderRadius: ZestTokens.borderPill,
          gradient: isDisabled
              ? const LinearGradient(colors: [Color(0xFFCBD5E1), Color(0xFF94A3B8)])
              : widget.isSuccess
                  ? const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)])
                  : ZestTokens.brandGradient,
          boxShadow: isDisabled ? null : ZestTokens.primaryButtonShadow,
        );
        break;

      case ZestButtonVariant.secondary:
        textColor = isDisabled ? ZestTokens.ink3 : ZestTokens.ink;
        decoration = BoxDecoration(
          color: ZestTokens.card,
          borderRadius: ZestTokens.borderPill,
          border: Border.all(color: ZestTokens.line, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B1220).withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        );
        break;

      case ZestButtonVariant.ghost:
        textColor = isDisabled ? ZestTokens.ink3 : ZestTokens.blue;
        decoration = const BoxDecoration(
          color: Colors.transparent,
          borderRadius: ZestTokens.borderPill,
        );
        break;

      case ZestButtonVariant.danger:
        textColor = Colors.white;
        decoration = BoxDecoration(
          color: isDisabled ? const Color(0xFFFCA5A5) : ZestTokens.danger,
          borderRadius: ZestTokens.borderPill,
          boxShadow: [
            BoxShadow(
              color: ZestTokens.danger.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        );
        break;
    }

    Widget content;
    if (widget.isLoading) {
      content = _ThreeDotLoader(color: textColor);
    } else if (widget.isSuccess) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            widget.text,
            style: ZestTokens.bodyBold.copyWith(color: Colors.white),
          ),
        ],
      );
    } else {
      Widget? effectiveIcon;

      final iconSource = widget.prefixIcon ?? widget.icon;
      if (iconSource != null) {
        if (iconSource is Widget) {
          effectiveIcon = iconSource;
        } else if (iconSource is IconData) {
          effectiveIcon = Icon(iconSource, size: 18, color: textColor);
        }
      }

      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (effectiveIcon != null) ...[
            effectiveIcon,
            const SizedBox(width: 8),
          ],
          Text(
            widget.text,
            style: ZestTokens.bodyBold.copyWith(
              color: textColor,
              fontSize: 15.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }


    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOutCubic,
      height: widget.height,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 24),
      decoration: decoration,
      child: Center(
        child: content,
      ),
    );

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: SizedBox(
        width: widget.fullWidth ? double.infinity : null,
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: (isDisabled || widget.isLoading) ? null : widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: button,
        ),
      ),
    );
  }
}

class _ThreeDotLoader extends StatefulWidget {
  final Color color;

  const _ThreeDotLoader({required this.color});

  @override
  State<_ThreeDotLoader> createState() => _ThreeDotLoaderState();
}

class _ThreeDotLoaderState extends State<_ThreeDotLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final double delay = index * 0.2;
            final double progress = (_controller.value - delay).clamp(0.0, 1.0);
            final double scale = 0.5 + 0.5 * (1.0 - (progress - 0.5).abs() * 2);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 7 * scale,
              height: 7 * scale,
              decoration: BoxDecoration(
                color: widget.color,
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}

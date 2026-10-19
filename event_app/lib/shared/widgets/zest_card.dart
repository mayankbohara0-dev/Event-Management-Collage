import 'package:flutter/material.dart';
import '../../core/theme/zest_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST CARD
/// Soft rounded white card (radius 28) with 1px line border and soft ambient shadow.
/// ─────────────────────────────────────────────────────────────────────────────

class ZestCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Gradient? gradient;
  final double radius;
  final bool hasBorder;
  final bool hasShadow;
  final Border? customBorder;

  const ZestCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20.0),
    this.onTap,
    this.backgroundColor,
    this.gradient,
    this.radius = ZestTokens.radiusCard,
    this.hasBorder = true,
    this.hasShadow = true,
    this.customBorder,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    final cardDecoration = BoxDecoration(
      color: gradient == null ? (backgroundColor ?? ZestTokens.card) : null,
      gradient: gradient,
      borderRadius: borderRadius,
      border: customBorder ??
          (hasBorder && gradient == null
              ? Border.all(color: ZestTokens.line, width: 1.0)
              : null),
      boxShadow: hasShadow ? ZestTokens.cardShadow : null,
    );

    Widget content = Container(
      padding: padding,
      decoration: cardDecoration,
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: content,
        ),
      );
    }

    return content;
  }
}

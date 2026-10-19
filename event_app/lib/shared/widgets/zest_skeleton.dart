import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/zest_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST SKELETON
/// Shimmer loading placeholder shaped like final content (never bare spinners).
/// ─────────────────────────────────────────────────────────────────────────────

class ZestSkeleton extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final BorderRadius? borderRadius;
  final bool circular;

  const ZestSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.radius = 12.0,
    this.borderRadius,
    this.circular = false,
  });


  const ZestSkeleton.circle({
    super.key,
    required double diameter,
  })  : width = diameter,
        height = diameter,
        radius = 999.0,
        borderRadius = null,
        circular = true;

  const ZestSkeleton.card({
    super.key,
    this.width = double.infinity,
    this.height = 140.0,
    this.radius = ZestTokens.radiusCard,
    this.borderRadius,
  }) : circular = false;

  const ZestSkeleton.text({
    super.key,
    this.width = 120.0,
    this.height = 14.0,
    this.radius = 6.0,
  })  : borderRadius = null,
        circular = false;


  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE9EEF5),
      highlightColor: const Color(0xFFF8FAFC),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: circular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circular
              ? null
              : (borderRadius ?? BorderRadius.circular(radius)),
        ),
      ),
    );
  }

}

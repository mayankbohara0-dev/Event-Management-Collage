import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// SkeletonLoader — a shimmer placeholder block.
class SkeletonLoader extends StatelessWidget {
  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 16,
    this.radius,
    this.circular = false,
  });

  final double? width;
  final double height;
  final double? radius;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey100,
      highlightColor: AppColors.grey200,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          shape: circular ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circular
              ? null
              : BorderRadius.circular(radius ?? AppRadius.sm),
        ),
      ),
    );
  }
}

/// SkeletonEventCard — a shimmer placeholder shaped like a HeroEventCard.
class SkeletonEventCard extends StatelessWidget {
  const SkeletonEventCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.grey100,
      highlightColor: AppColors.grey200,
      child: Container(
        width: 280,
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.grey100,
          borderRadius: AppRadius.circularXl3,
        ),
      ),
    );
  }
}

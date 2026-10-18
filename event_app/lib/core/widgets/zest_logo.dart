import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_colors.dart';

enum ZestLogoVariant {
  icon,
  markSmall,
  wordmark,
  lockup,
  watermark,
  mono,
}

/// Official Zest Brand Logo Widget
/// Clean, theme-aware, with pixel-perfect vector SVG rendering.
class ZestLogo extends StatelessWidget {
  const ZestLogo.icon({
    super.key,
    this.size = 48,
    this.color,
    this.opacity = 1.0,
  })  : variant = ZestLogoVariant.icon,
        height = null,
        isDark = false;

  const ZestLogo.markSmall({
    super.key,
    this.size = 36,
    this.color,
    this.opacity = 1.0,
  })  : variant = ZestLogoVariant.markSmall,
        height = null,
        isDark = false;

  const ZestLogo.wordmark({
    super.key,
    this.height = 24,
    this.color,
    this.opacity = 1.0,
  })  : variant = ZestLogoVariant.wordmark,
        size = null,
        isDark = false;

  const ZestLogo.lockup({
    super.key,
    this.height = 40,
    bool isDark = false,
    bool isDarkBg = false,
    this.color,
    this.opacity = 1.0,
  })  : variant = ZestLogoVariant.lockup,
        size = null,
        isDark = isDark || isDarkBg;

  const ZestLogo.watermark({
    super.key,
    this.size = 200,
    bool isLime = false,
    this.color,
    this.opacity = 0.08,
  })  : variant = ZestLogoVariant.watermark,
        height = null,
        isDark = isLime;

  final ZestLogoVariant variant;
  final double? size;
  final double? height;
  final Color? color;
  final double opacity;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final effectiveDark = isDark || Theme.of(context).brightness == Brightness.dark;

    Widget content;
    switch (variant) {
      case ZestLogoVariant.icon:
        content = SvgPicture.asset(
          'assets/brand/logo_icon.svg',
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
        break;

      case ZestLogoVariant.markSmall:
        content = SvgPicture.asset(
          'assets/brand/logo_mark_small.svg',
          width: size,
          height: size,
          fit: BoxFit.contain,
        );
        break;

      case ZestLogoVariant.wordmark:
        content = SvgPicture.asset(
          'assets/brand/logo_wordmark.svg',
          height: height,
          colorFilter: ColorFilter.mode(
            color ?? (effectiveDark ? AppColors.paper : AppColors.ink),
            BlendMode.srcIn,
          ),
          fit: BoxFit.contain,
        );
        break;

      case ZestLogoVariant.lockup:
        content = SvgPicture.asset(
          effectiveDark ? 'assets/brand/logo_lockup_dark.svg' : 'assets/brand/logo_lockup_light.svg',
          height: height,
          fit: BoxFit.contain,
        );
        break;

      case ZestLogoVariant.watermark:
        content = SvgPicture.asset(
          isDark ? 'assets/brand/logo_z_lime.svg' : 'assets/brand/logo_z_ink.svg',
          width: size,
          height: size,
          colorFilter: color != null ? ColorFilter.mode(color!, BlendMode.srcIn) : null,
          fit: BoxFit.contain,
        );
        break;

      case ZestLogoVariant.mono:
        content = SvgPicture.asset(
          'assets/brand/logo_mono.svg',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(color ?? AppColors.paper, BlendMode.srcIn),
          fit: BoxFit.contain,
        );
        break;
    }

    if (opacity < 1.0) {
      return Opacity(
        opacity: opacity,
        child: content,
      );
    }

    return content;
  }
}

// lib/features/admin/admin_colors.dart
//
// Single source of truth for all admin design tokens.
// Aligned with the Zest brand system:
//   Designjoy-style minimal light UI + blue lemon blob branding.

import 'package:flutter/material.dart';
import '../../core/theme/zest_tokens.dart';

class AdminColors {
  // ── Backgrounds (clean light Designjoy canvas) ───────────────────────────
  static const Color bg           = ZestTokens.page;
  static const Color sidebar      = Colors.white;
  static const Color surface      = Colors.white;
  static const Color surfaceLight = ZestTokens.fill;

  // ── Brand (Zest core & blue) ─────────────────────────────────────────────
  static const Color accent       = ZestTokens.blue;
  static const Color accentDark   = ZestTokens.blueDeep;
  static const Color accentBright = ZestTokens.core;
  static const Color onAccent     = Colors.white;
  static const Color gold         = ZestTokens.lemon;

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success      = ZestTokens.success;
  static const Color error        = ZestTokens.danger;
  static const Color warning      = ZestTokens.warning;

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary   = ZestTokens.ink;
  static const Color textSecondary = ZestTokens.ink2;

  // ── Border ───────────────────────────────────────────────────────────────
  static const Color border        = ZestTokens.line;
  static const Color borderCard    = ZestTokens.line;

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = ZestTokens.brandGradient;
  static const LinearGradient limeGradient = ZestTokens.brandGradient;
  static const LinearGradient brandGradient = ZestTokens.brandGradient;

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0B1220), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD84D), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

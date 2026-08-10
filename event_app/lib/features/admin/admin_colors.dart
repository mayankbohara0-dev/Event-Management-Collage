// lib/features/admin/admin_colors.dart
//
// Single source of truth for all admin design tokens.
// Import this instead of redefining AdminColors in each file.

import 'package:flutter/material.dart';

class AdminColors {
  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color bg           = Color(0xFFF7F7F7);
  static const Color sidebar      = Color(0xFFFFFFFF);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF9FAFB);

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color accent       = Color(0xFF00843D);
  static const Color accentDark   = Color(0xFF006630);
  static const Color gold         = Color(0xFFFFB700);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF00843D);
  static const Color error        = Color(0xFFE31837);
  static const Color warning      = Color(0xFFFFB700);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF616161);

  // ── Border ────────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E5E5);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF006630), Color(0xFF00843D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFB700), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

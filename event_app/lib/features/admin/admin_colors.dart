// lib/features/admin/admin_colors.dart
//
// Single source of truth for all admin design tokens.
// Import this instead of redefining AdminColors in each file.

import 'package:flutter/material.dart';

class AdminColors {
  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color bg           = Color(0xFFF9F8F6);
  static const Color sidebar      = Color(0xFFFFFFFF);
  static const Color surface      = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFFAF7F2);

  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color accent       = Color(0xFFFF6B00);
  static const Color accentDark   = Color(0xFFE55D00);
  static const Color gold         = Color(0xFFF9B233);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF10B981);
  static const Color error        = Color(0xFFEF4444);
  static const Color warning      = Color(0xFFF59E0B);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1E1F24);
  static const Color textSecondary = Color(0xFF6B6F7B);

  // ── Border ────────────────────────────────────────────────────────────────
  static const Color border = Color(0xFFEBE7DF);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFFF7A1A), Color(0xFFFF521B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF9B233), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

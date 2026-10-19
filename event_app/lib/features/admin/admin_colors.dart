// lib/features/admin/admin_colors.dart
//
// Single source of truth for all admin design tokens.
// Aligned with the Zest landing page design system:
//   ink blacks + neon lime accent + dark surfaces.

import 'package:flutter/material.dart';

class AdminColors {
  // ── Backgrounds (matches landing page ink canvas) ──────────────────────────
  static const Color bg           = Color(0xFF141416); // --color-ink
  static const Color sidebar      = Color(0xFF1D1D22); // --color-surface-dark
  static const Color surface      = Color(0xFF1D1D22); // --color-surface-dark
  static const Color surfaceLight = Color(0xFF26262C); // --color-surface-card

  // ── Brand (neon lime — official Zest brand color) ─────────────────────────
  static const Color accent       = Color(0xFFB8FF1A); // --color-lime-flat
  static const Color accentDark   = Color(0xFF7DFF2A); // --color-lime-2
  static const Color accentBright = Color(0xFFC2FF3A); // --color-lime-1
  static const Color onAccent     = Color(0xFF141416); // dark ink text for buttons
  static const Color gold         = Color(0xFFF9B233); // --color-mustard

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF10B981);
  static const Color error        = Color(0xFFEF4444);
  static const Color warning      = Color(0xFFF59E0B);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFFFFFFFF); // --color-paper
  static const Color textSecondary = Color(0xFFA0A0B0); // --color-text-muted-dark

  // ── Border ────────────────────────────────────────────────────────────────
  static const Color border        = Color(0xFF2F3038); // --color-border-dark
  static const Color borderCard    = Color(0xFF3A3C47);

  // ── Gradients ─────────────────────────────────────────────────────────────
  /// Hero header gradient — neon lime (matches landing page lime canvas)
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFFC2FF3A), Color(0xFF7DFF2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient limeGradient = LinearGradient(
    colors: [Color(0xFFC2FF3A), Color(0xFF7DFF2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1D1D22), Color(0xFF26262C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF9B233), Color(0xFFFF9500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

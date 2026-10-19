import 'package:flutter/material.dart';
import 'app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Zest Typography — Neo-Bold & Gen Z
// Display & Titles: Bricolage Grotesque (weight 800, tight tracking ~-3% of size)
// Body & UI: Inter (neutral, ultra-readable)
//
// Spec sizes:
//   Screen title 38sp; section title 24sp; card title 27sp; event row title 17sp
//   body 15sp; caption 12-13sp weight 700; big number 56sp (journey points)
//   splash wordmark 78sp; stat number 30sp; ticket title 28sp
//   event detail title 38sp; profile name 32sp; leaderboard title 38sp
// ─────────────────────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _displayFont({
    required double fontSize,
    required FontWeight fontWeight,
    Color color = AppColors.ink,
    double height = 1.0,
    double? letterSpacing,
  }) {
    // Spec: tight negative letter spacing ~-3% of font size
    final ls = letterSpacing ?? -(fontSize * 0.03);
    return TextStyle(
      fontFamily: 'Bricolage Grotesque',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: ls,
    );
  }

  static TextStyle _bodyFont({
    required double fontSize,
    required FontWeight fontWeight,
    Color color = AppColors.ink,
    double height = 1.45,
    double letterSpacing = 0.0,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // ── Giant Display (56-78sp) ──────────────────────────────────────────────────
  /// Journey / points big number — 56sp w800
  static TextStyle display56 = _displayFont(fontSize: 56, fontWeight: FontWeight.w800, height: 1.0);
  /// Splash wordmark — 78sp w800
  static TextStyle display78 = _displayFont(fontSize: 78, fontWeight: FontWeight.w800, height: 1.0);
  /// Legacy large display
  static TextStyle display72 = _displayFont(fontSize: 72, fontWeight: FontWeight.w800, height: 0.95);
  static TextStyle display64 = _displayFont(fontSize: 64, fontWeight: FontWeight.w800, height: 1.0);
  static TextStyle display48 = _displayFont(fontSize: 48, fontWeight: FontWeight.w800, height: 1.05);

  // ── Screen / Section Titles (24-40sp, weight 800, tight tracking) ─────────
  /// Screen title — 38sp (Home, Explore, Leaderboard, Event Detail)
  static TextStyle title38 = _displayFont(fontSize: 38, fontWeight: FontWeight.w800, height: 1.1);
  /// Profile name — 32sp
  static TextStyle title32 = _displayFont(fontSize: 32, fontWeight: FontWeight.w800, height: 1.15);
  /// Section title / header — 24sp
  static TextStyle title24 = _displayFont(fontSize: 24, fontWeight: FontWeight.w800, height: 1.2);
  /// Stat number — 30sp
  static TextStyle title30 = _displayFont(fontSize: 30, fontWeight: FontWeight.w800, height: 1.2);
  /// Ticket title — 28sp
  static TextStyle title28 = _displayFont(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2);
  /// Card title (carousel) — 27sp
  static TextStyle title27 = _displayFont(fontSize: 27, fontWeight: FontWeight.w800, height: 1.2);
  /// Greeting / Hi name — 22sp
  static TextStyle title22 = _displayFont(fontSize: 22, fontWeight: FontWeight.w800, height: 1.3);
  /// Event row title — 17sp
  static TextStyle title17 = _displayFont(fontSize: 17, fontWeight: FontWeight.w800, height: 1.3);

  // ── Legacy aliases (backward compat) ──────────────────────────────────────
  static TextStyle title40 = _displayFont(fontSize: 40, fontWeight: FontWeight.w800, height: 1.1);
  static TextStyle title36 = _displayFont(fontSize: 36, fontWeight: FontWeight.w800, height: 1.1);
  static TextStyle title20 = _displayFont(fontSize: 20, fontWeight: FontWeight.w800, height: 1.3);

  // ── Section Headers ────────────────────────────────────────────────────────
  static TextStyle sectionHeader = _displayFont(fontSize: 18, fontWeight: FontWeight.w800);

  // ── Body (Inter) ───────────────────────────────────────────────────────────
  static TextStyle body16 = _bodyFont(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.ink);
  /// Primary body text — 15sp
  static TextStyle body15 = _bodyFont(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.ink);
  static TextStyle body14 = _bodyFont(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.grey600);

  // ── Labels / Semibold ──────────────────────────────────────────────────────
  static TextStyle label16Bold = _bodyFont(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink);
  static TextStyle label14Bold = _bodyFont(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink);
  static TextStyle label13     = _bodyFont(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey600);

  // ── Captions (12-13sp weight 700 per spec) ────────────────────────────────
  /// Caption 13sp — date/subtitle on carousel cards, 70% opacity
  static TextStyle caption13 = _bodyFont(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.grey600);
  /// Caption 12sp — small labels
  static TextStyle caption12 = _bodyFont(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.grey400);
  static TextStyle caption11 = _bodyFont(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.grey400);

  // ── Button (Bold Gen Z) ────────────────────────────────────────────────────
  /// Primary button label — 17sp w800 per spec
  static TextStyle button = _displayFont(
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  static TextStyle buttonSmall = _displayFont(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
  );

  // ── Pill Tag / Chip Label ─────────────────────────────────────────────────
  /// Event card pill tag — 12sp w800 on ink pill with lime text
  static TextStyle pillTag = _displayFont(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AppColors.lime,
  );

  // ── Overline / Category Tags ──────────────────────────────────────────────
  static TextStyle overline = _displayFont(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
    color: AppColors.grey600,
  );

  // ── Semantic aliases for common components ────────────────────────────────
  static TextStyle bodyMedium = body15;
  static TextStyle bodySmall  = body14;
  static TextStyle caption    = caption12;
  static TextStyle metaLabel  = overline;
}

import 'package:flutter/material.dart';
import 'app_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Zest Typography — Neo-Bold & Gen Z
// Display & Titles: Bricolage Grotesque (weight 800, tight tracking)
// Body & UI: Inter (neutral, ultra-readable)
// ─────────────────────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  static TextStyle _displayFont({
    required double fontSize,
    required FontWeight fontWeight,
    Color color = AppColors.ink,
    double height = 1.0,
    double letterSpacing = -0.04,
  }) {
    return TextStyle(
      fontFamily: 'Bricolage Grotesque',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
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

  // ── Display (Giant Numbers 48-72sp) ─────────────────────────────────────────
  static TextStyle display72 = _displayFont(fontSize: 72, fontWeight: FontWeight.w800, height: 0.95);
  static TextStyle display64 = _displayFont(fontSize: 64, fontWeight: FontWeight.w800, height: 1.0);
  static TextStyle display48 = _displayFont(fontSize: 48, fontWeight: FontWeight.w800, height: 1.05);

  // ── Titles (32-40sp, weight 800 with tight tracking) ────────────────────────
  static TextStyle title40 = _displayFont(fontSize: 40, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -0.05);
  static TextStyle title36 = _displayFont(fontSize: 36, fontWeight: FontWeight.w800, height: 1.1, letterSpacing: -0.045);
  static TextStyle title32 = _displayFont(fontSize: 32, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.04);
  static TextStyle title28 = _displayFont(fontSize: 28, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.035);
  static TextStyle title24 = _displayFont(fontSize: 24, fontWeight: FontWeight.w800, height: 1.25, letterSpacing: -0.03);
  static TextStyle title20 = _displayFont(fontSize: 20, fontWeight: FontWeight.w800, height: 1.3, letterSpacing: -0.02);

  // ── Section Headers ─────────────────────────────────────────────────────────
  static TextStyle sectionHeader = _displayFont(fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.02);

  // ── Body (Inter) ────────────────────────────────────────────────────────────
  static TextStyle body16 = _bodyFont(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.ink);
  static TextStyle body15 = _bodyFont(fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.ink);
  static TextStyle body14 = _bodyFont(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.grey600);

  // ── Labels / Semibold ───────────────────────────────────────────────────────
  static TextStyle label16Bold = _bodyFont(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink);
  static TextStyle label14Bold = _bodyFont(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink);
  static TextStyle label13 = _bodyFont(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.grey600);

  // ── Captions (12sp) ─────────────────────────────────────────────────────────
  static TextStyle caption12 = _bodyFont(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.grey400);
  static TextStyle caption11 = _bodyFont(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.grey400);

  // ── Button (Bold Gen Z) ─────────────────────────────────────────────────────
  static TextStyle button = _displayFont(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    letterSpacing: -0.01,
  );

  static TextStyle buttonSmall = _displayFont(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    letterSpacing: -0.01,
  );

  // ── Overline / Category Tags ────────────────────────────────────────────────
  static TextStyle overline = _displayFont(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.8,
    color: AppColors.grey600,
  );
}

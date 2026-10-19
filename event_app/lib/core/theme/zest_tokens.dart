import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST DESIGN TOKENS
/// "Add some zest to your campus life."
/// Minimal, calm, modern light system inspired by Designjoy.
/// ─────────────────────────────────────────────────────────────────────────────

abstract class ZestTokens {
  // ── Brand Colors ─────────────────────────────────────────────────────────
  static const Color sky = Color(0xFF38BDF8);
  static const Color core = Color(0xFF0AA5F0);
  static const Color blue = Color(0xFF0063F0);
  static const Color blueDeep = Color(0xFF0050C8);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [sky, blue],
  );

  static const RadialGradient glowGradient = RadialGradient(
    colors: [Colors.white, core],
  );

  // ── Neutrals ─────────────────────────────────────────────────────────────
  static const Color ink = Color(0xFF0B1220);
  static const Color ink2 = Color(0xFF5B6577);
  static const Color ink3 = Color(0xFF8A93A5);
  static const Color page = Color(0xFFF5F7FB);
  static const Color card = Color(0xFFFFFFFF);
  static const Color line = Color(0xFFE6EAF2);
  static const Color fill = Color(0xFFEEF2F8);

  // ── Semantic ─────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF16B364);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = core;

  // ── Playful Accents (use only inside gradient tiles/badges/mascots) ─────
  static const Color lemon = Color(0xFFFFD84D);
  static const Color coral = Color(0xFFFF6B8A);
  static const Color aqua = Color(0xFF6CE3FF);
  static const Color lavender = Color(0xFF8E8BEA);
  static const Color mint = Color(0xFF3DDC97);

  // ── Category Tile Gradients ──────────────────────────────────────────────
  static const LinearGradient techGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [blue, aqua],
  );

  static const LinearGradient culturalGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [coral, lemon],
  );

  static const LinearGradient sportsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mint, aqua],
  );

  static const LinearGradient workshopsGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lavender, blue],
  );

  static const LinearGradient artGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [coral, lavender],
  );

  static const LinearGradient quizGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [lemon, mint],
  );

  static LinearGradient categoryGradient(String? category) {
    final lower = (category ?? '').toLowerCase();
    if (lower.contains('tech') || lower.contains('hack') || lower.contains('code')) return techGradient;
    if (lower.contains('cultur') || lower.contains('dance') || lower.contains('music')) return culturalGradient;
    if (lower.contains('sport') || lower.contains('game')) return sportsGradient;
    if (lower.contains('work') || lower.contains('seminar')) return workshopsGradient;
    if (lower.contains('art') || lower.contains('design')) return artGradient;
    if (lower.contains('quiz') || lower.contains('brain')) return quizGradient;
    return brandGradient;
  }


  // ── Radii ────────────────────────────────────────────────────────────────
  static const double radiusInput = 16.0;
  static const double radiusCard = 28.0;
  static const double radiusHero = 32.0;
  static const double radiusPill = 999.0;

  static const BorderRadius borderInput = BorderRadius.all(Radius.circular(radiusInput));
  static const BorderRadius borderCard = BorderRadius.all(Radius.circular(radiusCard));
  static const BorderRadius borderHero = BorderRadius.all(Radius.circular(radiusHero));
  static const BorderRadius borderPill = BorderRadius.all(Radius.circular(radiusPill));

  // ── Spacing (8px grid) ───────────────────────────────────────────────────
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  static const double horizontalPadding = 20.0;

  // ── Shadows ──────────────────────────────────────────────────────────────
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0F0B1220), // rgba(11, 18, 32, 0.06)
      blurRadius: 30,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> primaryButtonShadow = [
    BoxShadow(
      color: Color(0x400063F0), // rgba(0, 99, 240, 0.25)
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> navBarShadow = [
    BoxShadow(
      color: Color(0x140B1220), // rgba(11, 18, 32, 0.08)
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  // ── Motion Tokens ────────────────────────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 180);
  static const Duration durationBase = Duration(milliseconds: 320);
  static const Duration durationSlow = Duration(milliseconds: 600);

  static const Curve curveDefault = Curves.easeOutCubic;
  static const Curve curveBack = Curves.easeOutBack;

  // ── Typography Scale (Inter + Instrument Serif Italic) ───────────────────
  static TextStyle get display => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.03 * 34,
        color: ink,
        height: 1.15,
      );

  static TextStyle get title => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.02 * 24,
        color: ink,
        height: 1.2,
      );

  static TextStyle get section => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01 * 18,
        color: ink,
        height: 1.25,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: ink2,
        height: 1.5,
      );

  static TextStyle get bodyBold => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: ink,
        height: 1.5,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: ink3,
        height: 1.4,
      );

  static TextStyle get labelCaps => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1 * 11,
        color: ink3,
      );

  /// Single accent word only, in Instrument Serif Italic
  static TextStyle get accentItalic => GoogleFonts.instrumentSerif(
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w400,
        color: blue,
      );
}

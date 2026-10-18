import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Zest Brand Color System
// "Add some zest to your campus life."
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Neo-Bold Lime & Ink Brand Colors ─────────────────────────────────────────
  /// Official Zest Neon Lime
  static const Color lime = Color(0xFFB8FF1A);
  static const Color lime1 = Color(0xFFC2FF3A);
  static const Color lime2 = Color(0xFF7DFF2A);

  /// Official Zest Ink Blacks
  static const Color ink = Color(0xFF141416);
  static const Color surfaceDark = Color(0xFF1D1D22);
  static const Color surfaceCard = Color(0xFF26262C);
  static const Color borderDark = Color(0xFF2F3038);

  /// Paper & Off-Whites
  static const Color paper = Color(0xFFFFFFFF);
  static const Color offwhite = Color(0xFFF4F5EF);
  static const Color borderLight = Color(0xFFE7E8E0);

  // ── Brand Accents (used sparingly) ──────────────────────────────────────────
  static const Color coral = Color(0xFFF0577A);
  static const Color coralLight = Color(0xFFFDE8EE);
  static const Color lavender = Color(0xFF8E8BEA);
  static const Color lavenderLight = Color(0xFFEFEEFB);
  static const Color mustard = Color(0xFFF9B233);
  static const Color mustardLight = Color(0xFFFEF3D9);
  static const Color aqua = Color(0xFF6CE3FF);
  static const Color aquaLight = Color(0xFFE5FAFF);
  static const Color mint = Color(0xFF35D49A);
  static const Color mintLight = Color(0xFFE6FAF3);
  static const Color teal = Color(0xFF1F7A6B);
  static const Color tealLight = Color(0xFFE0F2EF);
  static const Color orange = Color(0xFFF58A4B);
  static const Color orangeLight = Color(0xFFFEEDE0);

  // ── Zest Signature ──────────────────────────────────────────────────────────
  static const Color zestOrange = Color(0xFFF9B233);

  // ── Neutrals / Charcoal ────────────────────────────────────────────────────
  static const Color charcoal = Color(0xFF23242A);
  static const Color charcoalMid = Color(0xFF2E2F38);
  static const Color charcoalLight = Color(0xFF3A3C47);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);

  static const Color grey50  = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF2F2F4);
  static const Color grey200 = Color(0xFFE6E6EA);
  static const Color grey300 = Color(0xFFD0D0D8);
  static const Color grey400 = Color(0xFFA0A0B0);
  static const Color grey600 = Color(0xFF505060);
  static const Color grey800 = Color(0xFF2A2A35);

  // ── Soft Pastel Backgrounds ────────────────────────────────────────────────
  static const Color bgCream    = Color(0xFFFBF8DC);
  static const Color bgBlush    = Color(0xFFFBE4F2);
  static const Color bgPeach    = Color(0xFFFBE3C4);
  static const Color bgMint     = Color(0xFFE0F2EF);
  static const Color bgLavender = Color(0xFFEFEEFB);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color error        = Color(0xFFE53935);
  static const Color errorLight   = Color(0xFFFFEBEE);
  static const Color success      = Color(0xFF1F7A6B);
  static const Color successLight = Color(0xFFE0F2EF);
  static const Color warning      = Color(0xFFF9B233);
  static const Color warningLight = Color(0xFFFEF3D9);
  static const Color info         = Color(0xFF8E8BEA);
  static const Color infoLight    = Color(0xFFEFEEFB);

  // ── Surface / Background ──────────────────────────────────────────────────
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color background     = Color(0xFFF7F6F3);
  static const Color backgroundDark = Color(0xFF1C1D24);

  // ── Legacy aliases (backward-compat during migration) ─────────────────────
  static const Color primary         = coral;
  static const Color accent          = teal;
  static const Color green           = teal;
  static const Color yellow          = mustard;
  static const Color periwinkle      = lavender;
  static const Color periwinkleLight = lavenderLight;
  static const Color gold            = mustard;
  static const Color textPrimary   = charcoal;
  static const Color textSecondary = grey600;
  static const Color grey500       = grey400;
  static const Color grey900       = charcoal;

  // ── Official Neo-Bold Lime Gradient ──────────────────────────────────────
  static const LinearGradient limeGradient = LinearGradient(
    colors: [Color(0xFFC2FF3A), Color(0xFF7DFF2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient zestGradient = LinearGradient(
    colors: [Color(0xFFF9B233), Color(0xFFF58A4B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1F7A6B), Color(0xFF155247)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient coralGradient = LinearGradient(
    colors: [Color(0xFFF0577A), Color(0xFFE8396A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient lavenderGradient = LinearGradient(
    colors: [Color(0xFF8E8BEA), Color(0xFF6E6BCC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkPillGradient = LinearGradient(
    colors: [Color(0xFF23242A), Color(0xFF2E2F38)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card gradients for HeroEventCard palette rotation
  static const List<LinearGradient> heroCardGradients = [
    LinearGradient(colors: [Color(0xFF8E8BEA), Color(0xFF6E6BCC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFF9B233), Color(0xFFF58A4B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFF1F7A6B), Color(0xFF155247)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    LinearGradient(colors: [Color(0xFFF0577A), Color(0xFFE8396A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
  ];

  // Legacy gradient aliases
  static const LinearGradient cardGradient1  = heroGradient;
  static const LinearGradient cardGradient2  = zestGradient;
  static const LinearGradient yellowGradient = zestGradient;
  // Legacy Color aliases (used in existing screens as backgroundColor)
  static const Color greenLight  = tealLight;
  static const Color goldLight   = mustardLight;
  static const Color accentLight = tealLight;
  static const Color yellowLight = mustardLight;
}

// ─────────────────────────────────────────────────────────────────────────────
// ZestColors ThemeExtension — Typed, theme-aware semantic tokens
// ─────────────────────────────────────────────────────────────────────────────

@immutable
class ZestColors extends ThemeExtension<ZestColors> {
  const ZestColors({
    required this.lime,
    required this.limeGradient,
    required this.ink,
    required this.surfaceCard,
    required this.surfaceDark,
    required this.paper,
    required this.offwhite,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.coral,
    required this.lavender,
    required this.mustard,
    required this.aqua,
  });

  final Color lime;
  final LinearGradient limeGradient;
  final Color ink;
  final Color surfaceCard;
  final Color surfaceDark;
  final Color paper;
  final Color offwhite;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color coral;
  final Color lavender;
  final Color mustard;
  final Color aqua;

  static const light = ZestColors(
    lime: AppColors.lime,
    limeGradient: AppColors.limeGradient,
    ink: AppColors.ink,
    surfaceCard: AppColors.paper,
    surfaceDark: AppColors.surfaceDark,
    paper: AppColors.paper,
    offwhite: AppColors.offwhite,
    border: AppColors.borderLight,
    textPrimary: AppColors.ink,
    textSecondary: AppColors.grey600,
    coral: AppColors.coral,
    lavender: AppColors.lavender,
    mustard: AppColors.mustard,
    aqua: AppColors.aqua,
  );

  static const dark = ZestColors(
    lime: AppColors.lime,
    limeGradient: AppColors.limeGradient,
    ink: AppColors.ink,
    surfaceCard: AppColors.surfaceCard,
    surfaceDark: AppColors.surfaceDark,
    paper: AppColors.paper,
    offwhite: AppColors.surfaceDark,
    border: AppColors.borderDark,
    textPrimary: AppColors.paper,
    textSecondary: AppColors.grey400,
    coral: AppColors.coral,
    lavender: AppColors.lavender,
    mustard: AppColors.mustard,
    aqua: AppColors.aqua,
  );

  @override
  ZestColors copyWith({
    Color? lime,
    LinearGradient? limeGradient,
    Color? ink,
    Color? surfaceCard,
    Color? surfaceDark,
    Color? paper,
    Color? offwhite,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? coral,
    Color? lavender,
    Color? mustard,
    Color? aqua,
  }) {
    return ZestColors(
      lime: lime ?? this.lime,
      limeGradient: limeGradient ?? this.limeGradient,
      ink: ink ?? this.ink,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceDark: surfaceDark ?? this.surfaceDark,
      paper: paper ?? this.paper,
      offwhite: offwhite ?? this.offwhite,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      coral: coral ?? this.coral,
      lavender: lavender ?? this.lavender,
      mustard: mustard ?? this.mustard,
      aqua: aqua ?? this.aqua,
    );
  }

  @override
  ZestColors lerp(ThemeExtension<ZestColors>? other, double t) {
    if (other is! ZestColors) return this;
    return ZestColors(
      lime: Color.lerp(lime, other.lime, t)!,
      limeGradient: limeGradient,
      ink: Color.lerp(ink, other.ink, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceDark: Color.lerp(surfaceDark, other.surfaceDark, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      offwhite: Color.lerp(offwhite, other.offwhite, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      lavender: Color.lerp(lavender, other.lavender, t)!,
      mustard: Color.lerp(mustard, other.mustard, t)!,
      aqua: Color.lerp(aqua, other.aqua, t)!,
    );
  }
}

extension ZestThemeContext on BuildContext {
  ZestColors get zestColors => Theme.of(this).extension<ZestColors>() ?? ZestColors.light;
}


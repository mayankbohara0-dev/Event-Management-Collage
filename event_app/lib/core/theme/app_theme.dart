import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Zest App Theme — "Neo-Bold Lime & Ink"
// Fully defined ColorScheme (zero Material purple leakage)
// Typography: Bricolage Grotesque for titles, Inter for body
// Dark theme is the signature look, light theme is ultra-crisp
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light {
    final colorScheme = const ColorScheme.light(
      primary: AppColors.lime,
      onPrimary: AppColors.ink,
      primaryContainer: AppColors.lime,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.ink,
      onSecondary: AppColors.lime,
      secondaryContainer: AppColors.surfaceDark,
      onSecondaryContainer: AppColors.paper,
      tertiary: AppColors.coral,
      onTertiary: AppColors.paper,
      surface: AppColors.paper,
      onSurface: AppColors.ink,
      error: AppColors.error,
      onError: AppColors.paper,
      outline: AppColors.borderLight,
      surfaceContainerHighest: AppColors.offwhite,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.offwhite,
      primaryColor: AppColors.lime,
      extensions: const [ZestColors.light],

      // Typography
      fontFamily: 'Inter',

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Bricolage Grotesque',
          color: AppColors.ink,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.03,
        ),
        iconTheme: IconThemeData(color: AppColors.ink),
      ),

      // Elevated button — Primary Neo-Bold Lime with Ink Text
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: AppColors.ink,
          minimumSize: const Size(double.infinity, 54),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.circularPill,
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'Bricolage Grotesque',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.01,
          ),
        ),
      ),

      // Filled button — Ink Pill (secondary button)
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.lime,
          minimumSize: const Size(double.infinity, 54),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.circularPill,
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'Bricolage Grotesque',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.01,
          ),
        ),
      ),

      // Outlined button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.ink, width: 2),
          minimumSize: const Size(double.infinity, 54),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.circularPill,
          ),
          textStyle: const TextStyle(
            fontFamily: 'Bricolage Grotesque',
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // Card — Chunky Bento Card
      cardTheme: const CardThemeData(
        color: AppColors.paper,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circularCard,
        ),
        margin: EdgeInsets.zero,
      ),

      // Input Decoration (Radius 20)
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paper,
        border: OutlineInputBorder(
          borderRadius: AppRadius.circularInput,
          borderSide: BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularInput,
          borderSide: BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularInput,
          borderSide: BorderSide(color: AppColors.ink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularInput,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(fontFamily: 'Inter', color: AppColors.grey400, fontSize: 15),
        labelStyle: TextStyle(fontFamily: 'Inter', color: AppColors.grey600, fontSize: 14),
      ),

      // Chip
      chipTheme: const ChipThemeData(
        backgroundColor: AppColors.paper,
        selectedColor: AppColors.lime,
        labelStyle: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.ink),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularPill),
        side: BorderSide(color: AppColors.borderLight, width: 1),
      ),

      // Dialog
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularCardLarge),
        elevation: 0,
      ),

      // Snack bar
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(fontFamily: 'Inter', color: AppColors.paper, fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Dark Theme (Signature Neo-Bold Ink & Lime) ───────────────────────────
  static ThemeData get dark {
    final colorScheme = const ColorScheme.dark(
      primary: AppColors.lime,
      onPrimary: AppColors.ink,
      primaryContainer: AppColors.lime,
      onPrimaryContainer: AppColors.ink,
      secondary: AppColors.paper,
      onSecondary: AppColors.ink,
      secondaryContainer: AppColors.surfaceCard,
      onSecondaryContainer: AppColors.paper,
      tertiary: AppColors.coral,
      onTertiary: AppColors.paper,
      surface: AppColors.surfaceCard,
      onSurface: AppColors.paper,
      error: AppColors.error,
      onError: AppColors.paper,
      outline: AppColors.borderDark,
      surfaceContainerHighest: AppColors.surfaceDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.ink,
      primaryColor: AppColors.lime,
      cardColor: AppColors.surfaceCard,
      extensions: const [ZestColors.dark],

      fontFamily: 'Inter',

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.paper,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Bricolage Grotesque',
          color: AppColors.paper,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.03,
        ),
        iconTheme: IconThemeData(color: AppColors.paper),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: AppColors.ink,
          minimumSize: const Size(double.infinity, 54),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.circularPill),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'Bricolage Grotesque',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.01,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.surfaceCard,
          foregroundColor: AppColors.paper,
          minimumSize: const Size(double.infinity, 54),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.circularPill),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: 'Bricolage Grotesque',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.01,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.paper,
          side: const BorderSide(color: AppColors.borderDark, width: 2),
          minimumSize: const Size(double.infinity, 54),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.circularPill),
          textStyle: const TextStyle(
            fontFamily: 'Bricolage Grotesque',
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      cardTheme: const CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularCard),
        margin: EdgeInsets.zero,
      ),

      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        border: OutlineInputBorder(
          borderRadius: AppRadius.circularInput,
          borderSide: BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularInput,
          borderSide: BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularInput,
          borderSide: BorderSide(color: AppColors.lime, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(fontFamily: 'Inter', color: AppColors.grey400, fontSize: 15),
      ),

      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularCardLarge),
        elevation: 0,
      ),

      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        contentTextStyle: TextStyle(fontFamily: 'Inter', color: AppColors.paper, fontSize: 14, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularMd),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Legacy alias
  static ThemeData get studentTheme => light;
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────
// Design Tokens — 7-Eleven inspired
// ─────────────────────────────────────────────
class AppColors {
  // Primary brand green
  static const Color green = Color(0xFF00843D);
  static const Color greenDark = Color(0xFF006630);
  static const Color greenLight = Color(0xFFE6F5ED);
  // Accent yellow
  static const Color yellow = Color(0xFFFFB700);
  static const Color yellowLight = Color(0xFFFFF8E0);
  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF111111);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF0F0F0);
  static const Color grey200 = Color(0xFFE5E5E5);
  static const Color grey400 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF222222);
  // Semantic
  static const Color error = Color(0xFFE31837);
  static const Color success = Color(0xFF00843D);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F7F7);
  // Legacy aliases used across screens
  static const Color accent = green;
  static const Color primary = green;
  static const Color gold = yellow;
  static const Color textPrimary = black;
  static const Color textSecondary = grey600;
  static const Color grey300 = grey200;
  static const Color grey500 = grey400;
  static const Color grey900 = black;
  static const Color warning = Color(0xFFFFB700);
  static const Color successLight = Color(0xFFE6F5ED);
  static const Color goldLight = Color(0xFFFFF8E0);
  static const Color accentLight = Color(0xFFE6F5ED);

  static const LinearGradient cardGradient1 = LinearGradient(
    colors: [Color(0xFF00843D), Color(0xFF006630)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient cardGradient2 = LinearGradient(
    colors: [Color(0xFFFFB700), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [greenDark, green],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient yellowGradient = LinearGradient(
    colors: [Color(0xFFFFB700), Color(0xFFFF8C00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─────────────────────────────────────────────
// Theme
// ─────────────────────────────────────────────
class AppTheme {
  static ThemeData get studentTheme => ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.green,
          secondary: AppColors.yellow,
          surface: AppColors.surface,
          background: AppColors.background,
        ),
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.green,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.black,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.green,
            foregroundColor: AppColors.white,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            elevation: 0,
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.black,
            side: const BorderSide(color: AppColors.grey200, width: 1.5),
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.grey100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.green, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintStyle: GoogleFonts.inter(color: AppColors.grey400, fontSize: 15),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.green,
          foregroundColor: AppColors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          titleTextStyle: GoogleFonts.inter(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          iconTheme: const IconThemeData(color: AppColors.white),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: AppColors.grey100,
          selectedColor: AppColors.green,
          labelStyle: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide.none,
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.white,
          selectedItemColor: AppColors.green,
          unselectedItemColor: AppColors.grey400,
          selectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500),
          elevation: 0,
        ),
      );
}

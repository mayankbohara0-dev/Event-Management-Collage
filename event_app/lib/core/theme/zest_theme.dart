import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'zest_tokens.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// ZEST THEME SYSTEM
/// Provides light theme (and architecture for dark theme).
/// ─────────────────────────────────────────────────────────────────────────────

abstract class ZestTheme {
  static ThemeData light() {
    final textTheme = GoogleFonts.interTextTheme().copyWith(
      displayLarge: ZestTokens.display,
      displayMedium: ZestTokens.title,
      titleLarge: ZestTokens.section,
      titleMedium: ZestTokens.bodyBold,
      bodyLarge: ZestTokens.bodyBold,
      bodyMedium: ZestTokens.body,
      bodySmall: ZestTokens.caption,
      labelLarge: ZestTokens.bodyBold,
      labelSmall: ZestTokens.labelCaps,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: ZestTokens.page,
      primaryColor: ZestTokens.blue,
      canvasColor: ZestTokens.page,
      cardColor: ZestTokens.card,
      dividerColor: ZestTokens.line,
      colorScheme: const ColorScheme.light(
        primary: ZestTokens.blue,
        onPrimary: Colors.white,
        secondary: ZestTokens.core,
        onSecondary: Colors.white,
        surface: ZestTokens.card,
        onSurface: ZestTokens.ink,
        error: ZestTokens.danger,
        onError: Colors.white,
        outline: ZestTokens.line,
      ),
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: ZestTokens.ink, size: 22),
        actionsIconTheme: IconThemeData(color: ZestTokens.ink, size: 22),
        titleTextStyle: TextStyle(
          color: ZestTokens.ink,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: const CardThemeData(
        color: ZestTokens.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: ZestTokens.borderCard,
          side: BorderSide(color: ZestTokens.line, width: 1),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ZestTokens.fill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: ZestTokens.ink3,
        ),
        labelStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: ZestTokens.ink2,
        ),
        border: OutlineInputBorder(
          borderRadius: ZestTokens.borderInput,
          borderSide: const BorderSide(color: ZestTokens.line, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ZestTokens.borderInput,
          borderSide: const BorderSide(color: ZestTokens.line, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ZestTokens.borderInput,
          borderSide: const BorderSide(color: ZestTokens.core, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: ZestTokens.borderInput,
          borderSide: const BorderSide(color: ZestTokens.danger, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: ZestTokens.borderInput,
          borderSide: const BorderSide(color: ZestTokens.danger, width: 1.5),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: ZestTokens.card,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: ZestTokens.borderCard,
          side: BorderSide(color: ZestTokens.line, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ZestTokens.card,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(ZestTokens.radiusHero)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: ZestTokens.fill,
        disabledColor: ZestTokens.fill,
        selectedColor: const Color(0xFFE6F4FE), // Blue tint
        secondarySelectedColor: const Color(0xFFE6F4FE),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: ZestTokens.ink2,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: ZestTokens.blue,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: ZestTokens.borderPill,
          side: BorderSide(color: ZestTokens.line, width: 1),
        ),
      ),
    );
  }
}

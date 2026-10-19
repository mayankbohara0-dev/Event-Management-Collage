import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_radius.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Zest App Theme — "Neo-Bold Lime & Ink"
// Fully defined ColorScheme (zero Material purple leakage)
// Typography: Bricolage Grotesque for titles, Inter for body
// Dark theme is the signature look, light theme is ultra-crisp
// Spec compliance: all component themes overridden per Section 1 of the brief
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // ── Shared text style helper ───────────────────────────────────────────────
  static const _displayFont = 'Bricolage Grotesque';
  static const _bodyFont    = 'Inter';

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary:                AppColors.lime,
      onPrimary:              AppColors.ink,
      primaryContainer:       AppColors.lime,
      onPrimaryContainer:     AppColors.ink,
      secondary:              AppColors.ink,
      onSecondary:            AppColors.lime,
      secondaryContainer:     AppColors.surfaceDark,
      onSecondaryContainer:   AppColors.paper,
      tertiary:               AppColors.coral,
      onTertiary:             AppColors.paper,
      surface:                AppColors.paper,
      onSurface:              AppColors.ink,
      surfaceContainerHighest: AppColors.offwhite,
      error:                  AppColors.error,
      onError:                AppColors.paper,
      outline:                AppColors.borderLight,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.offwhite,
      primaryColor: AppColors.lime,
      extensions: const [ZestColors.light],
      fontFamily: _bodyFont,

      // ── App Bar ──────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor:          Colors.transparent,
        foregroundColor:          AppColors.ink,
        elevation:                0,
        scrolledUnderElevation:   0,
        centerTitle:              false,
        systemOverlayStyle:       SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily:   _displayFont,
          color:        AppColors.ink,
          fontSize:     22,
          fontWeight:   FontWeight.w800,
          letterSpacing: -0.66,
        ),
        iconTheme: IconThemeData(color: AppColors.ink),
      ),

      // ── ElevatedButton — Primary Lime Pill ───────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: AppColors.ink,
          minimumSize:     const Size(double.infinity, 58),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.circularPill,
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily:   _displayFont,
            fontSize:     17,
            fontWeight:   FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),

      // ── FilledButton — Ink Pill ───────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: AppColors.lime,
          minimumSize:     const Size(double.infinity, 58),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.circularPill,
          ),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily:   _displayFont,
            fontSize:     17,
            fontWeight:   FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: const BorderSide(color: AppColors.ink, width: 2),
          minimumSize: const Size(double.infinity, 58),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.circularPill,
          ),
          textStyle: const TextStyle(
            fontFamily:   _displayFont,
            fontSize:     17,
            fontWeight:   FontWeight.w800,
          ),
        ),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color:     AppColors.paper,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.circularCard,
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Input ─────────────────────────────────────────────────────────────
      inputDecorationTheme: const InputDecorationTheme(
        filled:    true,
        fillColor: AppColors.paper,
        border: OutlineInputBorder(
          borderRadius: AppRadius.circularInput,
          borderSide:   BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularInput,
          borderSide:   BorderSide(color: AppColors.borderLight, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularInput,
          borderSide:   BorderSide(color: AppColors.ink, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularInput,
          borderSide:   BorderSide(color: AppColors.error, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle:  TextStyle(fontFamily: _bodyFont, color: AppColors.grey400, fontSize: 15),
        labelStyle: TextStyle(fontFamily: _bodyFont, color: AppColors.grey600, fontSize: 14),
      ),

      // ── Chip — spec: padding 11×18, inactive=card+border, active=ink+lime ─
      chipTheme: const ChipThemeData(
        backgroundColor:  AppColors.paper,
        selectedColor:    AppColors.ink,
        secondarySelectedColor: AppColors.ink,
        labelStyle: TextStyle(
          fontFamily:   _displayFont,
          fontSize:     13,
          fontWeight:   FontWeight.w800,
          color:        AppColors.ink,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily:   _displayFont,
          fontSize:     13,
          fontWeight:   FontWeight.w800,
          color:        AppColors.lime,
        ),
        padding:  EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        shape:    RoundedRectangleBorder(borderRadius: AppRadius.circularPill),
        side:     BorderSide(color: AppColors.borderLight, width: 1.5),
        showCheckmark: false,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.paper,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularCardLarge),
        elevation: 0,
      ),

      // ── SnackBar — spec: ink pill with lime bold text ─────────────────────
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(
          fontFamily:  _displayFont,
          color:       AppColors.lime,
          fontSize:    14,
          fontWeight:  FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularPill),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Switch — spec: 54×32, ink thumb when on, lime thumb ──────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.lime;
          return AppColors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.ink;
          return AppColors.borderLight;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── TabBar ────────────────────────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        labelColor:        AppColors.ink,
        unselectedLabelColor: AppColors.grey600,
        indicatorColor:    AppColors.lime,
        indicatorSize:     TabBarIndicatorSize.label,
        labelStyle: TextStyle(fontFamily: _displayFont, fontSize: 14, fontWeight: FontWeight.w800),
        unselectedLabelStyle: TextStyle(fontFamily: _bodyFont, fontSize: 14, fontWeight: FontWeight.w500),
      ),

      // ── Progress Indicator ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color:           AppColors.lime,
        linearTrackColor: AppColors.borderLight,
        linearMinHeight: 8,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color:     Color(0x1A141416), // 10% ink
        thickness: 1,
        space:     1,
      ),

      // ── ListTile ─────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding:  EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        titleTextStyle: TextStyle(fontFamily: _bodyFont, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
        subtitleTextStyle: TextStyle(fontFamily: _bodyFont, fontSize: 13, color: AppColors.grey600),
      ),

      // ── Bottom Sheet ─────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor:   AppColors.paper,
        modalElevation:    0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
    );
  }

  // ── Dark Theme (Signature Neo-Bold Ink & Lime) ───────────────────────────
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary:               AppColors.lime,
      onPrimary:             AppColors.ink,
      primaryContainer:      AppColors.lime,
      onPrimaryContainer:    AppColors.ink,
      secondary:             AppColors.paper,
      onSecondary:           AppColors.ink,
      secondaryContainer:    AppColors.ink2,
      onSecondaryContainer:  AppColors.paper,
      tertiary:              AppColors.coral,
      onTertiary:            AppColors.paper,
      surface:               AppColors.ink2,   // dark card surface = ink2 (#1D1D22)
      onSurface:             Color(0xFFF4F5EF),
      surfaceContainerHighest: AppColors.ink3,
      error:                 AppColors.error,
      onError:               AppColors.paper,
      outline:               AppColors.borderDark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.ink,  // #141416 dark scaffold
      primaryColor: AppColors.lime,
      cardColor:    AppColors.ink2,            // #1D1D22 card bg per spec
      extensions: const [ZestColors.dark],
      fontFamily: _bodyFont,

      // ── App Bar ──────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor:        Colors.transparent,
        foregroundColor:        AppColors.paper,
        elevation:              0,
        scrolledUnderElevation: 0,
        centerTitle:            false,
        systemOverlayStyle:     SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontFamily:   _displayFont,
          color:        AppColors.paper,
          fontSize:     22,
          fontWeight:   FontWeight.w800,
          letterSpacing: -0.66,
        ),
        iconTheme: IconThemeData(color: AppColors.paper),
      ),

      // ── ElevatedButton — Lime Pill ────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lime,
          foregroundColor: AppColors.ink,
          minimumSize:     const Size(double.infinity, 58),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.circularPill),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily:   _displayFont,
            fontSize:     17,
            fontWeight:   FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),

      // ── FilledButton — SurfaceCard Pill ──────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink2,
          foregroundColor: AppColors.paper,
          minimumSize:     const Size(double.infinity, 58),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.circularPill),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily:   _displayFont,
            fontSize:     17,
            fontWeight:   FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.paper,
          side: const BorderSide(color: AppColors.borderDark, width: 2),
          minimumSize: const Size(double.infinity, 58),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.circularPill),
          textStyle: const TextStyle(
            fontFamily:   _displayFont,
            fontSize:     17,
            fontWeight:   FontWeight.w800,
          ),
        ),
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color:     AppColors.ink2,  // #1D1D22 per spec
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularCard),
        margin: EdgeInsets.zero,
      ),

      // ── Input ─────────────────────────────────────────────────────────────
      inputDecorationTheme: const InputDecorationTheme(
        filled:    true,
        fillColor: AppColors.ink2,
        border: OutlineInputBorder(
          borderRadius: AppRadius.circularInput,
          borderSide:   BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularInput,
          borderSide:   BorderSide(color: AppColors.borderDark, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.circularInput,
          borderSide:   BorderSide(color: AppColors.lime, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(fontFamily: _bodyFont, color: AppColors.grey400, fontSize: 15),
      ),

      // ── Chip — spec: inactive=ink2+border, active=ink+lime text ──────────
      chipTheme: const ChipThemeData(
        backgroundColor:  AppColors.ink2,
        selectedColor:    AppColors.ink,
        secondarySelectedColor: AppColors.ink,
        labelStyle: TextStyle(
          fontFamily:   _displayFont,
          fontSize:     13,
          fontWeight:   FontWeight.w800,
          color:        AppColors.paper,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily:   _displayFont,
          fontSize:     13,
          fontWeight:   FontWeight.w800,
          color:        AppColors.lime,
        ),
        padding:  EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        shape:    RoundedRectangleBorder(borderRadius: AppRadius.circularPill),
        side:     BorderSide(color: AppColors.borderDark, width: 1.5),
        showCheckmark: false,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.ink2,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularCardLarge),
        elevation: 0,
      ),

      // ── SnackBar — spec: ink pill, lime bold text ─────────────────────────
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: TextStyle(
          fontFamily:  _displayFont,
          color:       AppColors.lime,
          fontSize:    14,
          fontWeight:  FontWeight.w800,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.circularPill),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Switch — spec: 54×32, ink bg when on, lime thumb ─────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.lime;
          return AppColors.grey400;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return AppColors.ink;
          return AppColors.ink3;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── TabBar ────────────────────────────────────────────────────────────
      tabBarTheme: const TabBarThemeData(
        labelColor:          AppColors.lime,
        unselectedLabelColor: AppColors.grey400,
        indicatorColor:      AppColors.lime,
        indicatorSize:       TabBarIndicatorSize.label,
        labelStyle: TextStyle(fontFamily: _displayFont, fontSize: 14, fontWeight: FontWeight.w800),
        unselectedLabelStyle: TextStyle(fontFamily: _bodyFont, fontSize: 14, fontWeight: FontWeight.w500),
      ),

      // ── Progress Indicator ────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color:           AppColors.lime,
        linearTrackColor: AppColors.ink3,
        linearMinHeight: 8,
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color:     Color(0x1AF4F5EF), // 10% white/paper per spec
        thickness: 1,
        space:     1,
      ),

      // ── ListTile ──────────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding:  EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        titleTextStyle: TextStyle(fontFamily: _bodyFont, fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFFF4F5EF)),
        subtitleTextStyle: TextStyle(fontFamily: _bodyFont, fontSize: 13, color: AppColors.grey400),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.ink2,
        modalElevation:  0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
      ),
    );
  }

  // Legacy alias
  static ThemeData get studentTheme => light;
}

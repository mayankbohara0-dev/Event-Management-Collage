import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Zest Shadow Tokens — soft, low-opacity only
// ─────────────────────────────────────────────────────────────────────────────

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const List<BoxShadow> pill = [
    BoxShadow(
      color: Color(0x18000000),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> hero = [
    BoxShadow(
      color: Color(0x20000000),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  // Returns a colored glow shadow — use hex ARGB constant for best performance.
  static List<BoxShadow> colored(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.28),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}

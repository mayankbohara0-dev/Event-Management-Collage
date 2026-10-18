import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Zest Radius Tokens — chunky, rounded bento cards, flat surfaces
// Spec: cards 28-32, hero cards 40, inputs 20, pills fully rounded
// ─────────────────────────────────────────────────────────────────────────────

class AppRadius {
  AppRadius._();

  static const double xs   = 8.0;
  static const double sm   = 12.0;
  static const double md   = 16.0;
  static const double lg   = 20.0;
  static const double xl   = 24.0;
  static const double xl2  = 28.0;
  static const double xl3  = 32.0;
  static const double hero = 40.0;
  static const double pill = 999.0;

  // Semantic radius
  static const double card = 28.0;
  static const double cardLarge = 32.0;
  static const double heroCard = 40.0;
  static const double input = 20.0;

  static const BorderRadius circularXs   = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius circularSm   = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius circularMd   = BorderRadius.all(Radius.circular(md));
  static const BorderRadius circularLg   = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius circularXl   = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius circularXl2  = BorderRadius.all(Radius.circular(xl2));
  static const BorderRadius circularXl3  = BorderRadius.all(Radius.circular(xl3));
  static const BorderRadius circularHero = BorderRadius.all(Radius.circular(hero));
  static const BorderRadius circularCard = BorderRadius.all(Radius.circular(card));
  static const BorderRadius circularCardLarge = BorderRadius.all(Radius.circular(cardLarge));
  static const BorderRadius circularHeroCard = BorderRadius.all(Radius.circular(heroCard));
  static const BorderRadius circularInput = BorderRadius.all(Radius.circular(input));
  static const BorderRadius circularPill = BorderRadius.all(Radius.circular(pill));
}

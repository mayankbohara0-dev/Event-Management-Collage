import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Zest Radius Tokens — chunky, rounded bento cards, flat surfaces
// Spec: lime header 38, journey card 34, carousel card 34,
//       list row 26, thumbnail 20, ticket/settings 28-30, pill = 999
// ─────────────────────────────────────────────────────────────────────────────

class AppRadius {
  AppRadius._();

  // ── Primitive scale ───────────────────────────────────────────────────────
  static const double xs   = 8.0;
  static const double sm   = 12.0;
  static const double md   = 16.0;
  static const double lg   = 20.0;   // thumbnail (event list row)
  static const double xl   = 24.0;
  static const double xl2  = 28.0;   // ticket/settings cards
  static const double xl3  = 32.0;
  static const double hero = 40.0;
  static const double pill = 999.0;

  // ── Semantic radius tokens ─────────────────────────────────────────────────
  static const double card         = 28.0;   // bento/settings cards
  static const double cardLarge    = 32.0;   // auth cards
  static const double heroCard     = 40.0;   // legacy
  static const double input        = 20.0;   // text field / search pill

  // ── Spec-exact component tokens ────────────────────────────────────────────
  /// Lime header / leaderboard header — bottom corners radius 38
  static const double limeHeader      = 38.0;
  /// Journey (points) card radius 34
  static const double journeyCard     = 34.0;
  /// Event carousel card radius 34
  static const double carouselCard    = 34.0;
  /// Event list row radius 26
  static const double listRow         = 26.0;
  /// Event thumbnail inside list row radius 20 (same as lg)
  static const double thumbnail       = 20.0;
  /// Bottom sheet event banner — bottom corners only 42
  static const double bottomSheetBanner = 42.0;
  /// App icon tile on splash 42
  static const double appIconTile     = 42.0;
  /// Ticket card radius 30
  static const double ticketCard      = 30.0;
  /// Explore card radius 30
  static const double exploreCard     = 30.0;

  // ── BorderRadius constants ─────────────────────────────────────────────────
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

  // ── Spec-exact BorderRadius constants ─────────────────────────────────────
  static const BorderRadius circularLimeHeader  = BorderRadius.all(Radius.circular(limeHeader));
  static const BorderRadius circularJourneyCard = BorderRadius.all(Radius.circular(journeyCard));
  static const BorderRadius circularCarousel    = BorderRadius.all(Radius.circular(carouselCard));
  static const BorderRadius circularListRow     = BorderRadius.all(Radius.circular(listRow));
  static const BorderRadius circularTicket      = BorderRadius.all(Radius.circular(ticketCard));
  static const BorderRadius circularExplore     = BorderRadius.all(Radius.circular(exploreCard));

  /// Bottom sheet event banner: top corners none, bottom corners 42
  static const BorderRadius bottomSheetBannerRadius = BorderRadius.only(
    bottomLeft:  Radius.circular(bottomSheetBanner),
    bottomRight: Radius.circular(bottomSheetBanner),
  );

  /// Lime header: bottom corners only 38 (top corners squared for edge-to-edge)
  static const BorderRadius limeHeaderRadius = BorderRadius.only(
    bottomLeft:  Radius.circular(limeHeader),
    bottomRight: Radius.circular(limeHeader),
  );
}

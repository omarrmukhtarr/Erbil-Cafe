import 'package:flutter/material.dart';

/// ErbilCafe's palette, with each colour in the role v1 actually gave it.
///
/// The signature look is a **cream page carrying near-black cards** — not a
/// dark app. v1's Home, Menu, Profile and Booking screens all set
/// `backgroundColor: HexColor('#E6CCB2')` and drew their tiles in `#17191f`
/// with black section headings. Only the two full-bleed photo screens
/// (Shop_Screen, detail_page) were dark.
abstract final class AppColors {
  // ─── Brand ──────────────────────────────────────────────────────────

  /// The page. v1's scaffold background on most screens.
  static const cream = Color(0xFFE6CCB2);

  /// Cards and tiles sitting on the cream — near-black, as in v1's coffee tiles.
  static const cardDark = Color(0xFF17191F);

  /// Primary accent — prices, active tabs, icons, CTAs.
  static const accent = Color(0xFFD17842);

  /// Tertiary warm tone: dividers, secondary chips.
  static const tan = Color(0xFFDDB892);

  // ─── Immersive surfaces ─────────────────────────────────────────────

  /// Full-bleed photo screens (v1's Shop_Screen) and the dark theme's page.
  static const ink = Color(0xFF141921);

  /// v1's detail_page background — the deepest surface.
  static const inkDeep = Color(0xFF0C0F14);

  /// Elevated dark surface — sheets, nested tiles on a dark card.
  static const cardDarkAlt = Color(0xFF1F222A);

  /// Rating chips and image overlays.
  static const badge = Color(0xFF231715);

  /// Card shadow. Warm, not grey — it sits under a card on cream.
  static const shadow = Color(0xFF30221F);

  // ─── Text ───────────────────────────────────────────────────────────

  /// On the cream page. v1 used `Colors.black` for its section headings.
  static const onCream = Color(0xFF14110D);

  /// Secondary text on cream.
  static const onCreamMuted = Color(0xFF6B5B49);

  /// On a dark card.
  static const onCard = Color(0xFFF6F2ED);

  /// Secondary text on a dark card.
  static const onCardMuted = Color(0xFFAEAEAE);

  /// Inactive tabs and disabled labels on a dark card.
  static const onCardDisabled = Color(0xFF52555A);

  // ─── Brown ramp ─────────────────────────────────────────────────────

  static const brownDarkest = Color(0xFF1E130C);
  static const brownMid = Color(0xFF9A8478);
  static const brownWarm = Color(0xFFB86B3C);
  static const brownDeep = Color(0xFFB25E2B);

  /// A hair darker than the page, for inputs and wells on cream.
  static const creamSunken = Color(0xFFDCBFA1);

  /// A hair lighter than the page, for raised areas on cream.
  static const creamRaised = Color(0xFFF0DCC6);

  // ─── Semantic ───────────────────────────────────────────────────────

  static const success = Color(0xFF2E7D5B);
  static const successOnDark = Color(0xFF4FBF8F);
  static const warning = Color(0xFFB07A16);
  static const warningOnDark = Color(0xFFD9A441);
  static const error = Color(0xFFA83E3E);
  static const errorOnDark = Color(0xFFD97070);

  // ─── Gradients ──────────────────────────────────────────────────────

  /// Scrim under text sitting over a café photo.
  static const imageScrim = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xCC141921), Color(0xF2141921)],
    stops: [0.35, 0.75, 1],
  );

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, brownDeep],
  );
}

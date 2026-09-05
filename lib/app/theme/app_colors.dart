import 'package:flutter/material.dart';

/// ErbilCafe's palette.
///
/// Every value here was counted out of the v1 source — this is the app's own
/// identity, formalised rather than replaced. The counts in the comments are how
/// many times each colour appeared across the original screens.
abstract final class AppColors {
  // ─── Brand ──────────────────────────────────────────────────────────

  /// Primary accent (39 uses in v1) — prices, active tabs, icons, CTAs.
  static const accent = Color(0xFFD17842);

  /// Secondary (34 uses) — nav bar ground, headers, light surfaces.
  static const cream = Color(0xFFE6CCB2);

  /// Tertiary (7 uses) — dividers, subtle highlights.
  static const tan = Color(0xFFDDB892);

  // ─── Dark surfaces (the product's real look) ────────────────────────

  /// App background (33 uses).
  static const background = Color(0xFF141921);

  /// Cards and tiles (4 uses).
  static const surface = Color(0xFF17191F);

  /// Elevated surfaces and sheets (2 uses).
  static const surfaceAlt = Color(0xFF171B22);

  /// Rating chips and image overlays (6 uses).
  static const badge = Color(0xFF231715);

  /// Card shadow (6 uses).
  static const shadow = Color(0xFF30221F);

  // ─── Text ───────────────────────────────────────────────────────────

  static const textPrimary = Color(0xFFF5F5F5);

  /// Secondary text (12 uses).
  static const textMuted = Color(0xFFAEAEAE);

  /// Inactive tabs and disabled labels (3 uses).
  static const textDisabled = Color(0xFF52555A);

  // ─── Brown ramp, for gradients and depth ────────────────────────────

  static const brownDarkest = Color(0xFF1E130C);
  static const brownMid = Color(0xFF9A8478);
  static const brownWarm = Color(0xFFB86B3C);
  static const brownDeep = Color(0xFFB25E2B);

  // ─── Semantic ───────────────────────────────────────────────────────

  static const success = Color(0xFF3FA37A);
  static const warning = Color(0xFFD9A441);
  static const error = Color(0xFFC25A5A);

  // ─── Light theme surfaces ───────────────────────────────────────────
  //
  // A daylight counterpart for outdoor use. The accent is deliberately
  // unchanged across themes so the product still reads as ErbilCafe.

  static const lightBackground = Color(0xFFF7F4F0);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceAlt = Color(0xFFF1EBE3);
  static const lightTextPrimary = Color(0xFF141921);
  static const lightTextMuted = Color(0xFF6B6F76);
  static const lightBorder = Color(0xFFE2DAD0);

  // ─── Gradients ──────────────────────────────────────────────────────

  /// Scrim under text sitting over a café photo, as on v1's detail headers.
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

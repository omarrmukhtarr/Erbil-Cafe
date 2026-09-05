import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';

/// Builds the app's themes from the design tokens.
///
/// The light theme is the product's real identity: a **cream page carrying
/// near-black cards**, as v1 drew it. That means text colour depends on which
/// surface it sits on, so `onSurface` here is the colour for text on the cream
/// page — anything inside a dark card must use [AppColors.onCard], which the
/// `AppCard` widget applies for you.
///
/// v1's `theme.dart` set `fontFamily: "Muli"`, a font never declared in
/// pubspec.yaml, so every screen silently fell back to the platform default.
/// The families here are the ones actually bundled.
abstract final class AppTheme {
  static const _latin = 'RalewaySemi';

  /// Covers Kurdish Sorani and Arabic script.
  static const _arabicScript = 'Kurdish';

  static const _display = 'Poppins';

  /// Falls back to the Kurdish face so Sorani and Arabic glyphs render even
  /// when a string mixes scripts.
  static const _fallback = [_arabicScript, 'Montserrat'];

  // ─── Light: cream page, dark cards ──────────────────────────────────

  static ThemeData light() {
    final scheme = const ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.brownDeep,
      onSecondary: Colors.white,
      tertiary: AppColors.tan,
      onTertiary: AppColors.onCream,
      error: AppColors.error,
      onError: Colors.white,
      // The page itself.
      surface: AppColors.cream,
      onSurface: AppColors.onCream,
      // Inputs and wells sink slightly into the cream.
      surfaceContainerHighest: AppColors.creamSunken,
      onSurfaceVariant: AppColors.onCreamMuted,
      outline: Color(0xFFCBAF90),
      shadow: AppColors.shadow,
      inverseSurface: AppColors.cardDark,
      onInverseSurface: AppColors.onCard,
    );

    return _build(
      scheme: scheme,
      page: AppColors.cream,
      onPage: AppColors.onCream,
      onPageMuted: AppColors.onCreamMuted,
      cardColor: AppColors.cardDark,
      outline: const Color(0xFFCBAF90),
      overlayStyle: SystemUiOverlayStyle.dark,
    );
  }

  // ─── Dark: everything sinks to ink ──────────────────────────────────

  static ThemeData dark() {
    final scheme = const ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.cream,
      onSecondary: AppColors.ink,
      tertiary: AppColors.tan,
      onTertiary: AppColors.ink,
      error: AppColors.errorOnDark,
      onError: AppColors.ink,
      surface: AppColors.ink,
      onSurface: AppColors.onCard,
      surfaceContainerHighest: AppColors.cardDarkAlt,
      onSurfaceVariant: AppColors.onCardMuted,
      outline: Color(0xFF2A2F39),
      shadow: Colors.black,
      inverseSurface: AppColors.cream,
      onInverseSurface: AppColors.onCream,
    );

    return _build(
      scheme: scheme,
      page: AppColors.ink,
      onPage: AppColors.onCard,
      onPageMuted: AppColors.onCardMuted,
      // On a dark page a card must be *lighter*, not darker, or it disappears.
      cardColor: AppColors.cardDarkAlt,
      outline: const Color(0xFF2A2F39),
      overlayStyle: SystemUiOverlayStyle.light,
    );
  }

  static ThemeData _build({
    required ColorScheme scheme,
    required Color page,
    required Color onPage,
    required Color onPageMuted,
    required Color cardColor,
    required Color outline,
    required SystemUiOverlayStyle overlayStyle,
  }) {
    final textTheme = _textTheme(onPage, onPageMuted);

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: page,
      canvasColor: page,
      fontFamily: _latin,
      fontFamilyFallback: _fallback,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: page,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: onPage),
        actionsIconTheme: IconThemeData(color: onPage),
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: overlayStyle,
      ),

      cardTheme: CardThemeData(
        color: cardColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardR),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.35),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
          elevation: 0,
          minimumSize: const Size.fromHeight(54),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillR),
          textStyle: const TextStyle(
            fontFamily: _display,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillR),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onPage,
          side: BorderSide(color: outline),
          minimumSize: const Size.fromHeight(54),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillR),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accent,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          minimumSize: const Size(0, 44), // keeps the tap target ≥44pt
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: TextStyle(color: onPageMuted, fontSize: 14),
        labelStyle: TextStyle(color: onPageMuted, fontSize: 14),
        floatingLabelStyle: const TextStyle(
          color: AppColors.accent,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: onPageMuted,
        suffixIconColor: onPageMuted,
        border: _inputBorder(Colors.transparent),
        enabledBorder: _inputBorder(Colors.transparent),
        focusedBorder: _inputBorder(AppColors.accent, width: 1.6),
        errorBorder: _inputBorder(scheme.error),
        focusedErrorBorder: _inputBorder(scheme.error, width: 1.6),
        errorStyle: TextStyle(color: scheme.error, fontSize: 12),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: AppColors.accent,
        labelStyle: TextStyle(
          color: onPageMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 12),
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillR),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: page,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetR),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: page,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardR),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),

      dividerTheme: DividerThemeData(color: outline, thickness: 1, space: 1),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardDark,
        contentTextStyle: const TextStyle(color: AppColors.onCard),
        behavior: SnackBarBehavior.floating,
        insetPadding: const EdgeInsets.all(16),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.inputR),
      ),

      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppColors.accent),

      listTileTheme: ListTileThemeData(
        iconColor: onPageMuted,
        textColor: onPage,
        contentPadding: EdgeInsets.zero,
      ),

      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1.4}) =>
      OutlineInputBorder(
        borderRadius: AppRadius.inputR,
        borderSide: BorderSide(color: color, width: width),
      );

  /// Type scale.
  ///
  /// v1 mixed fontSize 36 headings with 11pt labels and no scale between them.
  /// This is a proper ramp with line heights that keep Kurdish and Arabic
  /// ascenders from clipping.
  static TextTheme _textTheme(Color primary, Color muted) => TextTheme(
        displayLarge: TextStyle(
          fontFamily: _display,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: primary,
          height: 1.25,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontFamily: _display,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: primary,
          height: 1.3,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontFamily: _display,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: primary,
          height: 1.35,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: primary,
          height: 1.4,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: primary, height: 1.55),
        bodyMedium: TextStyle(fontSize: 14, color: primary, height: 1.55),
        bodySmall: TextStyle(fontSize: 13, color: muted, height: 1.5),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: primary,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: muted,
          height: 1.4,
        ),
        labelSmall: TextStyle(fontSize: 11, color: muted, height: 1.45),
      );
}

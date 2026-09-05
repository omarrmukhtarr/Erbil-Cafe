import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';

/// Builds the app's Material 3 themes from the design tokens.
///
/// v1's `theme.dart` set `fontFamily: "Muli"`, a font that was never declared
/// in pubspec.yaml, so every screen silently fell back to the platform default.
/// The families here are the ones actually bundled.
abstract final class AppTheme {
  /// Latin UI face, carried over from v1.
  static const _latin = 'RalewaySemi';

  /// Covers Kurdish Sorani and Arabic script.
  static const _arabicScript = 'Kurdish';

  static const _display = 'Poppins';

  /// Falls back to the Kurdish face so Sorani and Arabic glyphs render even
  /// when a string mixes scripts.
  static const _fallback = [_arabicScript, 'Montserrat'];

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        background: AppColors.background,
        surface: AppColors.surface,
        surfaceAlt: AppColors.surfaceAlt,
        textPrimary: AppColors.textPrimary,
        textMuted: AppColors.textMuted,
        border: const Color(0xFF262A33),
      );

  static ThemeData light() => _build(
        brightness: Brightness.light,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        surfaceAlt: AppColors.lightSurfaceAlt,
        textPrimary: AppColors.lightTextPrimary,
        textMuted: AppColors.lightTextMuted,
        border: AppColors.lightBorder,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceAlt,
    required Color textPrimary,
    required Color textMuted,
    required Color border,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      // The accent is identical in both themes — it is the brand.
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.cream,
      onSecondary: AppColors.background,
      tertiary: AppColors.tan,
      onTertiary: AppColors.background,
      error: AppColors.error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
      surfaceContainerHighest: surfaceAlt,
      onSurfaceVariant: textMuted,
      outline: border,
      shadow: AppColors.shadow,
    );

    final textTheme = _textTheme(textPrimary, textMuted);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      fontFamily: _latin,
      fontFamilyFallback: _fallback,
      textTheme: textTheme,

      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),

      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardR),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.accent.withValues(alpha: 0.4),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.inputR),
          textStyle: const TextStyle(
            fontFamily: _display,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border),
          minimumSize: const Size.fromHeight(52),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.inputR),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.accent),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        hintStyle: TextStyle(color: textMuted, fontSize: 14),
        labelStyle: TextStyle(color: textMuted, fontSize: 14),
        floatingLabelStyle: const TextStyle(color: AppColors.accent),
        border: _inputBorder(border),
        enabledBorder: _inputBorder(border),
        focusedBorder: _inputBorder(AppColors.accent, width: 1.5),
        errorBorder: _inputBorder(AppColors.error),
        focusedErrorBorder: _inputBorder(AppColors.error, width: 1.5),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        selectedColor: AppColors.accent,
        labelStyle: TextStyle(color: textMuted, fontSize: 12),
        secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 12),
        side: BorderSide.none,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.pillR),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetR),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.cardR),
      ),

      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceAlt,
        contentTextStyle: TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.inputR),
      ),

      progressIndicatorTheme:
          const ProgressIndicatorThemeData(color: AppColors.accent),

      splashFactory: InkSparkle.splashFactory,
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: AppRadius.inputR,
        borderSide: BorderSide(color: color, width: width),
      );

  static TextTheme _textTheme(Color primary, Color muted) => TextTheme(
        displayLarge: TextStyle(
          fontFamily: _display,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          color: primary,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontFamily: _display,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: primary,
          height: 1.25,
        ),
        titleLarge: TextStyle(
          fontFamily: _display,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        bodyLarge: TextStyle(fontSize: 15, color: primary, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, color: primary, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, color: muted, height: 1.4),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
        labelSmall: TextStyle(fontSize: 11, color: muted),
      );
}

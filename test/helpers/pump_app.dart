import 'package:erbilcafe/app/theme/app_theme.dart';
import 'package:erbilcafe/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:erbilcafe/l10n/kurdish_material_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a widget inside the app's real theme and localizations.
///
/// Using the production theme means these tests catch a contrast or surface
/// regression, not just a layout one.
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    Locale locale = const Locale('en'),
    ThemeMode themeMode = ThemeMode.light,
    Size surfaceSize = const Size(390, 844),
  }) async {
    await binding.setSurfaceSize(surfaceSize);
    addTearDown(() => binding.setSurfaceSize(null));

    await pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: themeMode,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...KurdishLocalizations.delegates,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: widget,
      ),
    );
  }

  /// Fails if any RenderFlex overflowed while laying out.
  ///
  /// Kurdish and Arabic wrap taller than English, so a fixed-height tile that
  /// fits in one locale can overflow in another — that is a real bug this app
  /// has already hit twice.
  void expectNoOverflow() {
    final exception = takeException();
    expect(
      exception,
      isNull,
      reason: 'Layout overflowed: $exception',
    );
  }
}

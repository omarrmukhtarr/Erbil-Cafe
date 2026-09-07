import 'package:erbilcafe/app/app.dart';
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

    // The real app puts AppSettings above MaterialApp; screens that read it —
    // the profile tab, which now holds the language and theme pickers — assert
    // on its absence rather than silently rendering without it.
    await pumpWidget(
      _TestSettings(
        locale: locale,
        themeMode: themeMode,
        builder: (context, settingsLocale, settingsThemeMode) => MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settingsThemeMode,
          locale: settingsLocale ?? locale,
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

/// In-memory stand-in for the settings the real app persists, so a test can
/// tap the language and theme pickers and see the choice take effect.
class _TestSettings extends StatefulWidget {
  const _TestSettings({
    required this.locale,
    required this.themeMode,
    required this.builder,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final Widget Function(BuildContext, Locale?, ThemeMode) builder;

  @override
  State<_TestSettings> createState() => _TestSettingsState();
}

class _TestSettingsState extends State<_TestSettings> {
  Locale? _locale;
  late ThemeMode _themeMode = widget.themeMode;

  @override
  Widget build(BuildContext context) {
    return AppSettings(
      locale: _locale,
      themeMode: _themeMode,
      setLocale: (locale) async => setState(() => _locale = locale),
      setThemeMode: (mode) async => setState(() => _themeMode = mode),
      child: Builder(
        builder: (context) => widget.builder(context, _locale, _themeMode),
      ),
    );
  }
}

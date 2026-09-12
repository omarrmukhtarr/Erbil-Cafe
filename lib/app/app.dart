import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/network/api_client.dart';
import '../core/storage/app_preferences.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../l10n/app_localizations.dart';
import '../l10n/kurdish_material_localizations.dart';
import 'package:go_router/go_router.dart';

import '../features/notifications/data/push_service.dart';
import 'di/injector.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class ErbilCafeApp extends StatefulWidget {
  const ErbilCafeApp({super.key});

  @override
  State<ErbilCafeApp> createState() => _ErbilCafeAppState();
}

class _ErbilCafeAppState extends State<ErbilCafeApp> {
  late final _prefs = sl<AppPreferences>();
  late final _authCubit = sl<AuthCubit>();
  late final _router = sl<GoRouter>();

  late Locale? _locale = _prefs.locale;
  late ThemeMode _themeMode = _prefs.themeMode;

  @override
  void initState() {
    super.initState();

    // Wired here rather than in `main` because a tapped notification has to
    // navigate, and the router only exists once the app is up. A notification
    // that opened the app from cold is replayed by `getInitialMessage`, so
    // nothing is lost by waiting for this frame.
    sl<PushService>().listen(
      onOpen: _openFromNotification,
      locale: _locale?.languageCode,
    );
  }

  /// Routes a tapped notification to whatever it is about.
  ///
  /// The payloads the API sends carry `reservationId` and `cafeId`. A booking
  /// leads to the bookings list rather than to one booking, because there is
  /// no single-booking screen — and a list where the booking is visible is a
  /// better answer than a dead link.
  void _openFromNotification(Map<String, dynamic> data) {
    final cafeSlug = data['cafeSlug'] as String?;

    if (data['reservationId'] != null) {
      _router.go(Routes.bookings);
    } else if (cafeSlug != null && cafeSlug.isNotEmpty) {
      _router.go(Routes.cafe(cafeSlug));
    }
  }

  Future<void> _setLocale(Locale? locale) async {
    await _prefs.setLocale(locale);
    // Keep the API's Accept-Language in step, so café and menu text comes back
    // in the language the user just chose.
    sl<ApiClient>().setLocale(locale?.languageCode ?? 'ku');
    setState(() => _locale = locale);
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    await _prefs.setThemeMode(mode);
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: _authCubit)],
      child: AppSettings(
        locale: _locale,
        themeMode: _themeMode,
        setLocale: _setLocale,
        setThemeMode: _setThemeMode,
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context).appName,
          routerConfig: _router,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: _themeMode,
          locale: _locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            // Must precede the global delegates: Flutter has no `ku` entry, so
            // without these the framework's own strings fall back to English.
            ...KurdishLocalizations.delegates,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            // Clamp text scaling: v1 sized everything off a fixed 375×812
            // design, so very large system fonts broke layouts. This keeps
            // accessibility scaling while bounding the damage.
            final scale = MediaQuery.textScalerOf(context).clamp(
              minScaleFactor: 0.85,
              maxScaleFactor: 1.4,
            );

            // Flutter's own RTL list covers Arabic but not `ku`, so Sorani
            // would otherwise lay out left-to-right. Force the direction from
            // the resolved locale.
            final language = Localizations.localeOf(context).languageCode;
            final direction = (language == 'ku' || language == 'ar')
                ? TextDirection.rtl
                : TextDirection.ltr;

            return Directionality(
              textDirection: direction,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(textScaler: scale),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Exposes locale and theme controls to any screen without a bloc.
class AppSettings extends InheritedWidget {
  const AppSettings({
    required this.locale,
    required this.themeMode,
    required this.setLocale,
    required this.setThemeMode,
    required super.child,
    super.key,
  });

  final Locale? locale;
  final ThemeMode themeMode;
  final Future<void> Function(Locale?) setLocale;
  final Future<void> Function(ThemeMode) setThemeMode;

  static AppSettings of(BuildContext context) {
    final settings = context.dependOnInheritedWidgetOfExactType<AppSettings>();
    assert(settings != null, 'AppSettings is missing from the widget tree');
    return settings!;
  }

  @override
  bool updateShouldNotify(AppSettings oldWidget) =>
      locale != oldWidget.locale || themeMode != oldWidget.themeMode;
}

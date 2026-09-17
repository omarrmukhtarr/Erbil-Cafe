import 'package:flutter/foundation.dart';

/// Build-time configuration.
///
/// Nothing secret is hardcoded here. v1 committed a Google Maps API key
/// directly into `Location_Screen.dart` and `.env.dart`, which then leaked into
/// the public git history. Values now arrive through `--dart-define`:
///
/// ```
/// flutter run \
///   --dart-define=API_URL=http://10.0.2.2:3100/api/v1 \
///   --dart-define=MAPS_API_KEY=…
/// ```
abstract final class AppConfig {
  static const _apiUrlOverride = String.fromEnvironment('API_URL');

  /// Base URL of the ErbilCafe API.
  ///
  /// Falls back to a local backend when no override is supplied. The Android
  /// emulator reaches the host through 10.0.2.2, while the iOS simulator shares
  /// the host's own loopback — so the default has to be resolved at runtime
  /// rather than baked in as a constant.
  static String get apiUrl {
    if (_apiUrlOverride.isNotEmpty) return _apiUrlOverride;
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:3100/api/v1'
        // 127.0.0.1, not localhost: the local API binds IPv4 only, and
        // `localhost` resolves to ::1 first — every new connection was
        // refused over IPv6 before falling back.
        : 'http://127.0.0.1:3100/api/v1';
  }

  static const _webUrlOverride = String.fromEnvironment('WEB_URL');

  /// Where the public web pages live — terms, privacy, account deletion.
  ///
  /// They are served by the dashboard, so the app links to them rather than
  /// carrying a second copy of legal text that could drift. Locally that is
  /// the dashboard on 3101; a release build must pass `WEB_URL` once hosting
  /// is decided.
  static String get webUrl {
    if (_webUrlOverride.isNotEmpty) return _webUrlOverride;
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:3101'
        : 'http://127.0.0.1:3101';
  }

  static String get termsUrl => '$webUrl/terms';

  /// A café's public page — what a shared link opens. It shows the café in any
  /// browser and offers to open it in the app, so a link sent to someone
  /// without ErbilCafe still leads somewhere.
  static String cafePageUrl(String slug) => '$webUrl/c/$slug';

  /// Opens a café inside the app: `erbilcafe://app/cafe/<slug>`. The host is
  /// fixed so the path is exactly the router's own `/cafe/<slug>`.
  static String cafeAppLink(String slug) => 'erbilcafe://app/cafe/$slug';
  static String get privacyUrl => '$webUrl/privacy';

  /// The address the published privacy policy and terms already give.
  static const supportEmail = 'support@erbilcafe.app';

  /// Only used by the web build; the native SDKs read the key from their own
  /// platform config, which is not committed.
  static const mapsApiKey = String.fromEnvironment('MAPS_API_KEY');

  static const connectTimeout = Duration(seconds: 15);
  static const receiveTimeout = Duration(seconds: 20);

  /// How long cached café and menu data is served before refetching.
  static const cacheTtl = Duration(minutes: 10);

  /// Sentry DSN, supplied at build time.
  ///
  /// Empty disables error reporting entirely — a local checkout and every
  /// widget test run without an account anywhere, the same stance the API
  /// takes on `SENTRY_DSN` and `FCM_*`.
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static bool get errorReportingEnabled => sentryDsn.isNotEmpty;

  /// Names the build a crash came from, so a fixed bug stops being reported
  /// by phones that have not updated yet.
  static const releaseName = String.fromEnvironment(
    'SENTRY_RELEASE',
    defaultValue: 'erbilcafe@2.0.0',
  );

  static const isProduction = bool.fromEnvironment('dart.vm.product');
}

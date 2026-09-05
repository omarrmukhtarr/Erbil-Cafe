import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Build-time capabilities reported by the host platform.
///
/// The only consumer today is the map. Without a Maps API key the iOS SDK
/// raises an uncaught native exception the instant a map view is created —
/// which crashes the app and cannot be caught from Dart — and Android renders a
/// permanently blank tile. Asking first lets the Map tab show a usable fallback
/// instead of taking the app down.
abstract final class PlatformConfig {
  static const _channel = MethodChannel('erbilcafe/platform_config');

  static bool? _mapsConfigured;

  /// Cached after the first call; the answer cannot change while running.
  static Future<bool> mapsConfigured() async {
    if (_mapsConfigured != null) return _mapsConfigured!;

    if (kIsWeb) {
      // The web build takes its key from --dart-define instead.
      return _mapsConfigured =
          const String.fromEnvironment('MAPS_API_KEY').isNotEmpty;
    }

    try {
      final result = await _channel.invokeMethod<bool>('mapsConfigured');
      return _mapsConfigured = result ?? false;
    } on MissingPluginException {
      // An older host build without the channel — assume unconfigured rather
      // than risking the crash.
      return _mapsConfigured = false;
    } on PlatformException {
      return _mapsConfigured = false;
    }
  }

  @visibleForTesting
  static void debugSetMapsConfigured(bool? value) => _mapsConfigured = value;
}

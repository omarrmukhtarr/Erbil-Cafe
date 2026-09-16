import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';

/// Push notifications.
///
/// The backend has sent these since the reservation flow was built; the app
/// had no way to receive one. Bookings were confirmed and declined in silence.
///
/// Everything here is best-effort on purpose. A missing `google-services.json`
/// or an `Info.plist` from another Firebase project makes `initializeApp`
/// throw, and that must degrade to "no notifications" rather than to an app
/// that will not start — the same stance `PlatformConfig` takes on the Maps
/// key. [isAvailable] says which happened.
class PushService {
  PushService(this._api);

  final ApiClient _api;

  bool _initialised = false;
  String? _token;

  /// Whether Firebase started. False means pushes are simply off.
  bool get isAvailable => _initialised;

  /// The token currently registered with the API, if any.
  String? get token => _token;

  /// Set by [listen] so a notification tapped from a cold start can be
  /// replayed once the router exists.
  void Function(Map<String, dynamic> data)? _onOpen;

  /// Starts Firebase. Safe to call when nothing is configured.
  ///
  /// Does **not** ask for permission — that happens in [requestPermission],
  /// at a moment the user can connect to a reason.
  Future<void> init() => _starting ??= _start();

  /// The one start-up, shared by everyone who asks — `main` kicks it off
  /// without waiting, and [listen] waits for it.
  Future<void>? _starting;

  Future<void> _start() async {
    try {
      await Firebase.initializeApp();
      _initialised = true;
    } catch (error) {
      // Wrong project, missing plist, no google-services.json: all mean the
      // same thing to the person holding the phone.
      debugPrint('Push notifications unavailable: $error');
      _initialised = false;
    }
  }

  /// Asks the system for permission and returns whether it was granted.
  ///
  /// iOS only ever shows this dialog once in the lifetime of an install, so it
  /// is spent deliberately — after a booking is made, where "we will tell you
  /// when the café answers" is the obvious next sentence — and never at first
  /// launch, where it is a dialog about nothing.
  Future<bool> requestPermission() async {
    await init();
    if (!_initialised) return false;

    try {
      final settings = await FirebaseMessaging.instance.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (error) {
      debugPrint('Notification permission request failed: $error');
      return false;
    }
  }

  /// Registers this device against the signed-in account.
  ///
  /// Called after signing in, and again whenever the token is rotated — FCM
  /// reissues on reinstall, restore from backup, and occasionally on its own.
  /// The API upserts, so registering twice costs nothing.
  Future<void> registerDevice({String? locale}) async {
    await init();
    if (!_initialised) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;

      await _api.post<void>(
        '/notifications/devices',
        data: {
          'token': token,
          'platform': Platform.isIOS ? 'IOS' : 'ANDROID',
          if (locale != null) 'locale': locale,
        },
      );
      _token = token;
    } catch (error) {
      // A device that fails to register still works; it is just quiet.
      debugPrint('Could not register for notifications: $error');
    }
  }

  /// Detaches this device, so a shared phone does not keep receiving the
  /// previous account's bookings.
  Future<void> unregisterDevice() async {
    final token = _token;
    if (token == null) return;

    try {
      await _api.post<void>(
        '/notifications/devices/unregister',
        data: {'token': token},
      );
    } catch (error) {
      debugPrint('Could not unregister for notifications: $error');
    } finally {
      // Dropped locally either way: this account is done with this device.
      _token = null;
    }
  }

  /// Wires up taps and token rotation.
  ///
  /// [onOpen] receives the notification's `data` payload — `{ reservationId,
  /// cafeId }` — so the caller can route to whatever it refers to.
  Future<void> listen({
    required void Function(Map<String, dynamic> data) onOpen,
    String? locale,
  }) async {
    await init();
    if (!_initialised) return;
    _onOpen = onOpen;

    try {
      // Tapped while the app was in the background.
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpen);

      // Tapped while the app was not running at all. This is delivered once,
      // and only to whoever asks for it.
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null) _handleOpen(initial);

      // FCM rotates tokens without warning; a stale one is a silent device.
      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        _token = token;
        await registerDevice(locale: locale);
      });
    } catch (error) {
      debugPrint('Could not listen for notifications: $error');
    }
  }

  void _handleOpen(RemoteMessage message) {
    final handler = _onOpen;
    if (handler == null) return;

    // FCM data values are always strings on the wire.
    handler(message.data.map((key, value) => MapEntry(key, value)));
  }
}

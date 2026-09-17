import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

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
  ///
  /// [onReceive] runs for every push that arrives while the app is open, so
  /// the inbox badge can move without waiting for the next foreground.
  Future<void> listen({
    required void Function(Map<String, dynamic> data) onOpen,
    VoidCallback? onReceive,
    String? locale,
  }) async {
    await init();
    if (!_initialised) return;
    _onOpen = onOpen;

    try {
      // A push that arrives while the app is on screen is not shown by either
      // platform unless asked. iOS can be told to show its own banner; Android
      // cannot, so a local notification stands in for it there.
      await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
      if (Platform.isAndroid) await _setUpAndroidBanner();

      FirebaseMessaging.onMessage.listen((message) {
        onReceive?.call();
        if (Platform.isAndroid) _showAndroidBanner(message);
      });

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

  final _local = FlutterLocalNotificationsPlugin();

  /// The channel booking updates arrive on. High importance, because a café
  /// confirming a table for tonight is not something to find tomorrow.
  static const _channel = AndroidNotificationChannel(
    'bookings',
    'Bookings and updates',
    description: 'Booking confirmations, reminders and replies to your reviews.',
    importance: Importance.high,
  );

  Future<void> _setUpAndroidBanner() async {
    await _local.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        final handler = _onOpen;
        if (payload == null || handler == null) return;
        try {
          handler((jsonDecode(payload) as Map).cast<String, dynamic>());
        } catch (_) {
          // A payload from an older build; opening the app is enough.
        }
      },
    );

    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  Future<void> _showAndroidBanner(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    try {
      await _local.show(
        message.messageId.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (error) {
      debugPrint('Could not show a foreground notification: $error');
    }
  }

  void _handleOpen(RemoteMessage message) {
    final handler = _onOpen;
    if (handler == null) return;

    // FCM data values are always strings on the wire.
    handler(message.data.map((key, value) => MapEntry(key, value)));
  }
}

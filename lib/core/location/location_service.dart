import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// What the app is allowed to know about where the phone is.
enum LocationAccess {
  /// Permission given and location services on.
  granted,

  /// Not asked yet, or asked and refused this once — asking again is allowed.
  notDetermined,

  /// Refused for good. Only the system Settings app can change it.
  deniedForever,

  /// Location services are off for the whole phone.
  serviceOff,

  /// No location on this platform or in this environment (a widget test).
  unavailable,
}

/// A point, as far as the app needs one.
@immutable
class UserLocation {
  const UserLocation(this.lat, this.lng);

  final double lat;
  final double lng;
}

/// The phone's location, asked for only when a person asks for something
/// that needs it.
///
/// The permission dialog appears when someone taps "Use my location" or the
/// Near me chip — never at launch. Like the notification prompt, iOS shows it
/// once, and spending it before the user wants anything nearby spends it for
/// nothing.
///
/// Every call is wrapped: a platform without the plugin (a widget test) or a
/// phone whose GPS times out answers [LocationAccess.unavailable] rather than
/// throwing into a screen.
class LocationService {
  LocationService();

  /// Replaced in tests.
  static LocationService instance = LocationService();

  UserLocation? _last;
  DateTime? _lastAt;

  /// A fix younger than this is good enough to reuse. People walk slowly
  /// compared to how far apart cafés are.
  static const _fresh = Duration(minutes: 2);

  /// Where the phone was most recently found, if anywhere.
  UserLocation? get lastKnown => _last;

  /// The current permission state, without asking for anything.
  Future<LocationAccess> access() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return LocationAccess.serviceOff;
      }
      return _fromPermission(await Geolocator.checkPermission());
    } catch (error) {
      debugPrint('Location unavailable: $error');
      return LocationAccess.unavailable;
    }
  }

  /// Finds the phone, asking for permission first when [prompt] is true.
  ///
  /// Returns the access state and, when granted, the location. A recent fix is
  /// reused so moving between screens does not wait on the GPS each time.
  Future<(LocationAccess, UserLocation?)> locate({bool prompt = true}) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return (LocationAccess.serviceOff, null);
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && prompt) {
        permission = await Geolocator.requestPermission();
      }

      final access = _fromPermission(permission);
      if (access != LocationAccess.granted) return (access, null);

      final lastAt = _lastAt;
      if (_last != null &&
          lastAt != null &&
          DateTime.now().difference(lastAt) < _fresh) {
        return (LocationAccess.granted, _last);
      }

      // Last known first: it is instant, and on a phone that has been in the
      // same café for an hour it is as good as a new fix.
      final position = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(
              // City-block accuracy is plenty to sort cafés, and it arrives
              // in a fraction of the time a GPS-grade fix takes indoors.
              accuracy: LocationAccuracy.medium,
              timeLimit: Duration(seconds: 12),
            ),
          );

      _last = UserLocation(position.latitude, position.longitude);
      _lastAt = DateTime.now();
      return (LocationAccess.granted, _last);
    } on TimeoutException {
      return (LocationAccess.unavailable, null);
    } catch (error) {
      debugPrint('Could not get a location: $error');
      return (LocationAccess.unavailable, null);
    }
  }

  /// Sends the user where they can fix [access]: the app's own settings page
  /// for a permanent refusal, the phone's location settings when it is off.
  Future<void> openSettingsFor(LocationAccess access) async {
    try {
      if (access == LocationAccess.serviceOff) {
        await Geolocator.openLocationSettings();
      } else {
        await Geolocator.openAppSettings();
      }
    } catch (error) {
      debugPrint('Could not open settings: $error');
    }
  }

  static LocationAccess _fromPermission(LocationPermission permission) =>
      switch (permission) {
        LocationPermission.always ||
        LocationPermission.whileInUse =>
          LocationAccess.granted,
        LocationPermission.deniedForever => LocationAccess.deniedForever,
        LocationPermission.denied => LocationAccess.notDetermined,
        LocationPermission.unableToDetermine => LocationAccess.notDetermined,
      };
}

import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Guards the map's camera calls against a plugin regression.
///
/// google_maps_flutter_platform_interface 2.9.1 shipped
/// `CameraUpdateNewLatLngBounds.toJson()` emitting the discriminator
/// `'newLatLngZoom'` instead of `'newLatLngBounds'`. The iOS side then took the
/// wrong branch and called `[NSArray doubleValue]` on the bounds pair, which is
/// an unrecognised selector — the whole app aborted with SIGABRT the moment a
/// cluster was tapped.
///
/// Nothing in our own code could have prevented that, and no widget test would
/// have caught it, so the wire format is asserted here directly.
void main() {
  group('CameraUpdate wire format', () {
    test('newLatLngBounds is tagged as bounds, not zoom', () {
      final json = CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: const LatLng(36.18, 43.96),
          northeast: const LatLng(36.23, 44.03),
        ),
        80,
      ).toJson() as List<Object?>;

      expect(
        json.first,
        'newLatLngBounds',
        reason: 'a wrong tag routes the payload into the native zoom branch '
            'and aborts the process',
      );

      // The payload must be a pair of [lat, lng] pairs.
      final bounds = json[1]! as List<Object?>;
      expect(bounds, hasLength(2));
      expect(bounds[0], isA<List<Object?>>());
      expect((bounds[0]! as List<Object?>).first, isA<double>());
    });

    test('newLatLngZoom sends a single coordinate pair', () {
      final json = CameraUpdate.newLatLngZoom(
        const LatLng(36.19, 44.00),
        16,
      ).toJson() as List<Object?>;

      expect(json.first, 'newLatLngZoom');
      // A nested list here would abort the same way.
      expect(json[1], isA<List<Object?>>());
      expect((json[1]! as List<Object?>).first, isA<double>());
    });

    test('LatLngBounds rejects an inverted pair before it reaches native', () {
      expect(
        () => LatLngBounds(
          southwest: const LatLng(36.23, 44.03),
          northeast: const LatLng(36.18, 43.96),
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

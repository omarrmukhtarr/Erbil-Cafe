import 'package:erbilcafe/features/cafes/data/models/cafe.dart';
import 'package:erbilcafe/features/map/presentation/screens/cafe_clustering.dart';
import 'package:flutter_test/flutter_test.dart';

CafeMarker marker(String id, double lat, double lng) => CafeMarker(
      id: id,
      slug: id,
      name: id,
      lat: lat,
      lng: lng,
      ratingAvg: 4,
      reviewCount: 1,
      isOpenNow: true,
    );

void main() {
  group('CafeClustering', () {
    test('collapses cafés that would overlap on screen', () {
      // Three cafés within ~50m of each other in central Erbil.
      final cafes = [
        marker('a', 36.1911, 44.0091),
        marker('b', 36.1913, 44.0093),
        marker('c', 36.1912, 44.0092),
      ];

      final clusters = CafeClustering.cluster(cafes, 12);

      expect(clusters, hasLength(1));
      expect(clusters.first.count, 3);
      expect(clusters.first.isSingle, isFalse);
    });

    test('separates them again as the map zooms in', () {
      final cafes = [
        marker('a', 36.1911, 44.0091),
        marker('b', 36.1990, 44.0180),
      ];

      expect(CafeClustering.cluster(cafes, 11), hasLength(1));
      expect(CafeClustering.cluster(cafes, 16), hasLength(2));
    });

    test('never clusters past the street-level zoom', () {
      // Otherwise a café could sit permanently behind a bubble.
      final cafes = [
        marker('a', 36.19110, 44.00910),
        marker('b', 36.19111, 44.00911),
      ];

      final clusters =
          CafeClustering.cluster(cafes, CafeClustering.maxClusterZoom);

      expect(clusters, hasLength(2));
      expect(clusters.every((c) => c.isSingle), isTrue);
    });

    test('puts the bubble at the mean of its members', () {
      final clusters = CafeClustering.cluster([
        marker('a', 36.00, 44.00),
        marker('b', 36.10, 44.10),
      ], 8);

      expect(clusters, hasLength(1));
      expect(clusters.first.position.latitude, closeTo(36.05, 1e-9));
      expect(clusters.first.position.longitude, closeTo(44.05, 1e-9));
    });

    test('keeps a cluster id stable regardless of member order', () {
      final a = marker('a', 36.1911, 44.0091);
      final b = marker('b', 36.1912, 44.0092);

      // An unstable id would make Google Maps drop and re-add the marker on
      // every camera move, which flickers.
      final forward = CafeClustering.cluster([a, b], 12).first.id;
      final reversed = CafeClustering.cluster([b, a], 12).first.id;

      expect(forward, reversed);
    });

    test('handles an empty list and a single café', () {
      expect(CafeClustering.cluster(const [], 12), isEmpty);

      final one = CafeClustering.cluster([marker('a', 36.19, 44.00)], 12);
      expect(one, hasLength(1));
      expect(one.first.isSingle, isTrue);
      expect(one.first.id, 'a');
    });

    test('scales to a few hundred cafés without collapsing to one blob', () {
      // The case that motivated clustering: 300 cafés across the city.
      final cafes = [
        for (var i = 0; i < 300; i++)
          marker('c$i', 36.16 + (i % 30) * 0.003, 43.95 + (i ~/ 30) * 0.012),
      ];

      final wide = CafeClustering.cluster(cafes, 11);
      final close = CafeClustering.cluster(cafes, 16);

      expect(wide.length, lessThan(cafes.length));
      expect(close.length, greaterThan(wide.length));
      // Every café must remain reachable through exactly one pin.
      expect(
        wide.fold<int>(0, (sum, c) => sum + c.count),
        cafes.length,
      );
    });
  });
}

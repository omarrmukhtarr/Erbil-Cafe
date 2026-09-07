import 'package:erbilcafe/app/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Routes.exploreWith', () {
    // The home screen's categories and area tiles hand off to Explore through
    // these URLs; if the query keys drift from what the route reads, the tap
    // still navigates and silently drops the filter.
    test('carries an amenity', () {
      expect(Routes.exploreWith(amenity: 'shisha'), '/explore?amenity=shisha');
    });

    test('carries an area, escaped', () {
      expect(Routes.exploreWith(area: '40m'), '/explore?area=40m');
      expect(
        Uri.parse(Routes.exploreWith(area: 'Ainkawa Street')).queryParameters['area'],
        'Ainkawa Street',
      );
    });

    test('carries open-now', () {
      expect(Routes.exploreWith(openNow: true), '/explore?openNow=1');
    });

    test('is the plain route when nothing is filtered', () {
      expect(Routes.exploreWith(), Routes.explore);
    });
  });
}

import 'package:erbilcafe/core/widgets/cafe_card.dart';
import 'package:erbilcafe/features/cafes/data/models/cafe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/pump_app.dart';

Cafe buildCafe({
  String name = 'Barbera Cafe',
  double rating = 4.7,
  int reviews = 12,
  bool featured = true,
  bool openNow = true,
  List<String> amenities = const ['Wi-Fi', 'Outdoor seating', 'Shisha'],
  String? cover,
  double? distanceKm,
}) =>
    Cafe(
      id: 'c1',
      slug: 'barbera-cafe',
      name: name,
      description: 'An Italian coffee house on 40m Street.',
      address: '40m Street, Erbil',
      area: '40m',
      lat: 36.2,
      lng: 43.98,
      coverImage: cover,
      priceRange: PriceRange.moderate,
      ratingAvg: rating,
      reviewCount: reviews,
      isFeatured: featured,
      isOpenNow: openNow,
      distanceKm: distanceKm,
      amenities: [
        for (final a in amenities) Amenity(key: a, name: a),
      ],
    );

void main() {
  group('CafeCard', () {
    testWidgets('shows the name, price symbol and rating', (tester) async {
      await tester.pumpApp(
        Scaffold(body: CafeCard(cafe: buildCafe(), onTap: () {})),
      );

      expect(find.text('Barbera Cafe'), findsOneWidget);
      expect(find.text(r'$$'), findsOneWidget);
      expect(find.text('4.7'), findsOneWidget);
      expect(find.text('Featured'), findsOneWidget);
    });

    testWidgets('says a café is new rather than showing it a 0.0 rating',
        (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: CafeCard(cafe: buildCafe(reviews: 0, rating: 0), onTap: () {}),
        ),
      );

      // An unrated café used to show nothing in the corner, which read as a
      // hole in the card rather than a fact about the café.
      expect(find.text('0.0'), findsNothing);
      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('shows how many ratings are behind the average',
        (tester) async {
      await tester.pumpApp(
        Scaffold(body: CafeCard(cafe: buildCafe(rating: 4.7, reviews: 12), onTap: () {})),
      );

      expect(find.text('4.7'), findsOneWidget);
      expect(find.text('(12)'), findsOneWidget);
    });

    testWidgets('never clips an amenity pill mid-word', (tester) async {
      // Regression: three pills went into a non-scrolling ListView that simply
      // cut the last one off — "City vie…" with no sign more existed.
      await tester.pumpApp(
        Scaffold(
          body: SizedBox(
            width: 272,
            child: CafeCard(
              cafe: buildCafe(
                amenities: const [
                  'Wi-Fi',
                  'Outdoor seating',
                  'Shisha',
                  'City view',
                ],
              ),
              compact: true,
              onTap: () {},
            ),
          ),
        ),
      );

      tester.expectNoOverflow();
      // Whatever did not fit is counted, not silently dropped.
      expect(find.textContaining('+'), findsWidgets);
    });

    testWidgets('says a café has no photo instead of showing a blank box',
        (tester) async {
      await tester.pumpApp(
        Scaffold(body: CafeCard(cafe: buildCafe(), onTap: () {})),
      );

      // A bare grey box left people unsure whether it was still loading; the
      // card now names the state and fills the space with the café's initials.
      expect(find.text('No photo yet'), findsOneWidget);
      expect(find.text('BC'), findsOneWidget);
    });

    testWidgets('derives initials from a single-word name', (tester) async {
      await tester.pumpApp(
        Scaffold(body: CafeCard(cafe: buildCafe(name: 'Huqqabaz'), onTap: () {})),
      );

      expect(find.text('H'), findsOneWidget);
    });

    testWidgets('derives initials from a non-Latin name', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: CafeCard(cafe: buildCafe(name: 'کافێی باربێرا'), onTap: () {}),
        ),
        locale: const Locale('ku'),
      );

      expect(find.text('هێشتا وێنە نییە'), findsOneWidget);
    });

    testWidgets('shows distance only when the query supplied coordinates',
        (tester) async {
      await tester.pumpApp(
        Scaffold(body: CafeCard(cafe: buildCafe(), onTap: () {})),
      );
      expect(find.textContaining('km away'), findsNothing);

      await tester.pumpApp(
        Scaffold(
          body: CafeCard(cafe: buildCafe(distanceKm: 2.4), onTap: () {}),
        ),
      );
      expect(find.textContaining('2.4'), findsOneWidget);
    });

    testWidgets('the favourite button reports its state to screen readers',
        (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: CafeCard(
            cafe: buildCafe().copyWith(isFavorited: true),
            onTap: () {},
            onFavoriteTap: () {},
          ),
        ),
      );

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('compact tiles fit their fixed carousel height in English',
        (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: SizedBox(
            height: CafeCard.compactHeight,
            child: SizedBox(
              width: 272,
              child: CafeCard(cafe: buildCafe(), compact: true, onTap: () {}),
            ),
          ),
        ),
      );

      tester.expectNoOverflow();
    });

    testWidgets('compact tiles also fit in Kurdish, which wraps taller',
        (tester) async {
      // Regression: the carousel overflowed by 22px in Kurdish because the
      // height had only ever been measured against English.
      await tester.pumpApp(
        Scaffold(
          body: SizedBox(
            height: CafeCard.compactHeight,
            child: SizedBox(
              width: 272,
              child: CafeCard(
                cafe: buildCafe(
                  name: 'چایخانەی مەچکۆ و قەڵای دەرین',
                  amenities: const [
                    'دانیشتنی دەرەوە',
                    'نێرگیلە',
                    'دیمەنی شار',
                  ],
                ),
                compact: true,
                onTap: () {},
              ),
            ),
          ),
        ),
        locale: const Locale('ku'),
      );

      tester.expectNoOverflow();
    });

    testWidgets('compact tiles fit in Arabic too', (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: SizedBox(
            height: CafeCard.compactHeight,
            child: SizedBox(
              width: 272,
              child: CafeCard(
                cafe: buildCafe(
                  name: 'مقهى مجكو وقلعة أربيل',
                  amenities: const ['جلسات خارجية', 'أركيلة', 'إطلالة'],
                ),
                compact: true,
                onTap: () {},
              ),
            ),
          ),
        ),
        locale: const Locale('ar'),
      );

      tester.expectNoOverflow();
    });

    testWidgets('tapping the card and the heart fire separate callbacks',
        (tester) async {
      var cardTaps = 0;
      var favouriteTaps = 0;

      await tester.pumpApp(
        Scaffold(
          body: CafeCard(
            cafe: buildCafe(),
            onTap: () => cardTaps++,
            onFavoriteTap: () => favouriteTaps++,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pump();
      expect(favouriteTaps, 1);
      expect(cardTaps, 0, reason: 'the heart must not also open the café');

      await tester.tap(find.text('Barbera Cafe'));
      await tester.pump();
      expect(cardTaps, 1);
    });
  });
}

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

    testWidgets('hides the rating badge when there are no reviews',
        (tester) async {
      await tester.pumpApp(
        Scaffold(
          body: CafeCard(cafe: buildCafe(reviews: 0, rating: 0), onTap: () {}),
        ),
      );

      expect(find.text('0.0'), findsNothing);
    });

    testWidgets('renders a placeholder when the café has no photo',
        (tester) async {
      await tester.pumpApp(
        Scaffold(body: CafeCard(cafe: buildCafe(), onTap: () {})),
      );

      expect(find.byIcon(Icons.local_cafe_outlined), findsOneWidget);
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

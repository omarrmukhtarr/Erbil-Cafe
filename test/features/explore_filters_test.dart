import 'package:erbilcafe/app/di/injector.dart';
import 'package:erbilcafe/features/cafes/data/models/cafe.dart';
import 'package:erbilcafe/features/cafes/data/repositories/cafe_repository.dart';
import 'package:erbilcafe/features/cafes/presentation/screens/explore_screen.dart';
import 'package:erbilcafe/features/favorites/data/favorites_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

class _MockCafes extends Mock implements CafeRepository {}

class _MockFavorites extends Mock implements FavoritesRepository {}

/// One result, so the list never falls back to the empty state — which offers
/// a "Clear all" button of its own and would make the chip ambiguous to find.
const _oneCafe = Cafe(
  id: 'c1',
  slug: 'barbera-cafe',
  name: 'Barbera Cafe',
  description: '',
  address: '40m Street, Erbil',
  area: '40m',
  lat: 36.2,
  lng: 43.98,
  priceRange: PriceRange.moderate,
  ratingAvg: 4.7,
  reviewCount: 12,
  isFeatured: false,
  isOpenNow: true,
  amenities: [],
);

/// Every filter chip is a toggle.
///
/// The complaint this pins: an applied area chip could not be taken off. The
/// only way back was a separate "all areas" chip that read like a seventh
/// area, so a wrong tap felt permanent.
void main() {
  late _MockCafes cafes;

  /// Every query the screen has asked the repository for, in order.
  ///
  /// Recorded here rather than read back with `verify(...).captured`, which
  /// marks the calls it reads as verified and so cannot be asked twice in one
  /// test.
  late List<CafeQuery> queries;

  setUpAll(() => registerFallbackValue(const CafeQuery()));

  setUp(() async {
    cafes = _MockCafes();
    queries = [];

    when(() => cafes.list(any())).thenAnswer((invocation) async {
      queries.add(invocation.positionalArguments.first as CafeQuery);
      return const Paginated<Cafe>(items: [_oneCafe]);
    });
    when(() => cafes.areas()).thenAnswer(
      (_) async => const [
        AreaCount(area: 'Ainkawa', count: 41),
        AreaCount(area: '40m', count: 18),
      ],
    );
    when(() => cafes.amenities()).thenAnswer(
      (_) async => const [
        AmenityCount(key: 'wifi', name: 'Wi-Fi', count: 90),
        AmenityCount(key: 'shisha', name: 'Shisha', count: 55),
      ],
    );

    await sl.reset();
    sl
      ..registerSingleton<CafeRepository>(cafes)
      ..registerSingleton<FavoritesRepository>(_MockFavorites());
  });

  tearDown(() => sl.reset());

  CafeQuery lastQuery() => queries.last;

  /// A filter chip, and not the café card behind it.
  ///
  /// The card carries its own "Open now", its area and its price symbol, so a
  /// bare text finder matches two widgets. Chips are the only thing on this
  /// screen drawn inside an [AnimatedContainer].
  Finder chip(String label) => find.descendant(
        of: find.byType(AnimatedContainer),
        matching: find.text(label),
      );

  /// Wide enough that the whole chip row is on screen at once.
  ///
  /// The row scrolls horizontally on a phone, and dragging it to reach a chip
  /// would be testing the ListView rather than the toggles.
  // Grew from 1100 when Near me and Sort joined the front of the row.
  const wide = Size(1500.0, 844.0);

  Future<void> pumpExplore(WidgetTester tester,
      {String? initialAmenity}) async {
    await tester.pumpApp(
      ExploreScreen(initialAmenity: initialAmenity),
      surfaceSize: wide,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an area chip applies on the first tap and clears on the second',
      (tester) async {
    await pumpExplore(tester);

    await tester.tap(chip('Ainkawa \u00b7 41'));
    await tester.pumpAndSettle();
    expect(lastQuery().area, 'Ainkawa');

    await tester.tap(chip('Ainkawa \u00b7 41'));
    await tester.pumpAndSettle();
    expect(lastQuery().area, isNull,
        reason: 'tapping an applied area chip must take it off');
  });

  testWidgets('open now, price and amenity chips all toggle off',
      (tester) async {
    await pumpExplore(tester);

    await tester.tap(chip('Open now'));
    await tester.pumpAndSettle();
    expect(lastQuery().openNow, isTrue);
    await tester.tap(chip('Open now'));
    await tester.pumpAndSettle();
    expect(lastQuery().openNow, isNull);

    await tester.tap(chip(r'$$'));
    await tester.pumpAndSettle();
    expect(lastQuery().priceRange, PriceRange.moderate);
    await tester.tap(chip(r'$$'));
    await tester.pumpAndSettle();
    expect(lastQuery().priceRange, isNull);

    await tester.tap(chip('Wi-Fi'));
    await tester.pumpAndSettle();
    expect(lastQuery().amenities, ['wifi']);
    await tester.tap(chip('Wi-Fi'));
    await tester.pumpAndSettle();
    expect(lastQuery().amenities, isEmpty);
  });

  testWidgets('there is no "all areas" chip, and clear appears only when a '
      'filter is applied', (tester) async {
    await pumpExplore(tester);

    expect(chip('All areas'), findsNothing);
    expect(chip('Clear all'), findsNothing);

    await tester.tap(chip('40m \u00b7 18'));
    await tester.pumpAndSettle();
    expect(chip('Clear all'), findsOneWidget);

    await tester.tap(chip('Clear all'));
    await tester.pumpAndSettle();
    expect(lastQuery().hasFilters, isFalse);
    expect(chip('Clear all'), findsNothing);
  });

  testWidgets('a filter the screen arrived with is still removable',
      (tester) async {
    // Arriving from the home screen's category strip used to leave a filter
    // applied with nothing in the UI able to clear it.
    await pumpExplore(tester, initialAmenity: 'wifi');

    expect(lastQuery().amenities, ['wifi']);

    await tester.tap(chip('Wi-Fi'));
    await tester.pumpAndSettle();
    expect(lastQuery().amenities, isEmpty);
  });
}

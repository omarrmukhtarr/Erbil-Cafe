import 'package:erbilcafe/app/di/injector.dart';
import 'package:erbilcafe/core/location/location_service.dart';
import 'package:erbilcafe/features/cafes/data/models/cafe.dart';
import 'package:erbilcafe/features/cafes/data/repositories/cafe_repository.dart';
import 'package:erbilcafe/features/cafes/presentation/screens/explore_screen.dart';
import 'package:erbilcafe/features/favorites/data/favorites_repository.dart';
import 'package:erbilcafe/features/home/presentation/widgets/nearby_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

class _MockCafes extends Mock implements CafeRepository {}

class _MockFavorites extends Mock implements FavoritesRepository {}

/// Location without a GPS: a scripted permission state and a fixed point.
class _FakeLocation extends LocationService {
  _FakeLocation(this.state, {this.afterPrompt});

  LocationAccess state;
  final LocationAccess? afterPrompt;
  int prompts = 0;

  static const erbil = UserLocation(36.19, 44.01);

  @override
  Future<LocationAccess> access() async => state;

  @override
  Future<(LocationAccess, UserLocation?)> locate({bool prompt = true}) async {
    if (prompt && state == LocationAccess.notDetermined) {
      prompts++;
      state = afterPrompt ?? state;
    }
    return (state, state == LocationAccess.granted ? erbil : null);
  }
}

const _near = Cafe(
  id: 'c1',
  slug: 'machko',
  name: 'Machko',
  description: '',
  address: '',
  lat: 36.19,
  lng: 44.01,
  priceRange: PriceRange.budget,
  ratingAvg: 4.6,
  reviewCount: 10,
  isFeatured: false,
  isOpenNow: true,
  amenities: [],
  distanceKm: 0.3,
);

void main() {
  late _MockCafes cafes;
  late List<CafeQuery> queries;

  setUpAll(() => registerFallbackValue(const CafeQuery()));

  setUp(() async {
    await sl.reset();
    cafes = _MockCafes();
    queries = [];
    when(() => cafes.list(any())).thenAnswer((invocation) async {
      queries.add(invocation.positionalArguments.first as CafeQuery);
      return const Paginated<Cafe>(items: [_near]);
    });
    when(() => cafes.areas()).thenAnswer((_) async => const []);
    when(() => cafes.amenities()).thenAnswer((_) async => const []);
    sl
      ..registerSingleton<CafeRepository>(cafes)
      ..registerSingleton<FavoritesRepository>(_MockFavorites());
  });

  tearDown(() {
    LocationService.instance = LocationService();
    return sl.reset();
  });

  group('CafeQuery near me', () {
    test('turns on with a point and off again, leaving other filters', () {
      const base = CafeQuery(openNow: true);
      final near = base.copyWith(
          lat: 36.19, lng: 44.01, radiusKm: 40.0, sort: 'distance');

      expect(near.isNearMe, isTrue);
      expect(near.toParams(), containsPair('sort', 'distance'));
      expect(near.toParams(), containsPair('lat', 36.19));

      final off =
          near.copyWith(lat: null, lng: null, radiusKm: null, sort: 'rating');
      expect(off.isNearMe, isFalse);
      expect(off.toParams().containsKey('lat'), isFalse);
      expect(off.openNow, isTrue);
    });
  });

  group('Home "Near you"', () {
    testWidgets('does not ask for location on its own', (tester) async {
      final location = _FakeLocation(
        LocationAccess.notDetermined,
        afterPrompt: LocationAccess.granted,
      );
      LocationService.instance = location;

      await tester.pumpApp(
          const Scaffold(body: SingleChildScrollView(child: NearbySection())));
      await tester.pumpAndSettle();

      expect(location.prompts, 0);
      expect(find.text('Use my location'), findsOneWidget);
      expect(queries, isEmpty);
    });

    testWidgets('asks when the button is pressed, then lists the closest cafés',
        (tester) async {
      final location = _FakeLocation(
        LocationAccess.notDetermined,
        afterPrompt: LocationAccess.granted,
      );
      LocationService.instance = location;

      await tester.pumpApp(
          const Scaffold(body: SingleChildScrollView(child: NearbySection())));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Use my location'));
      await tester.pumpAndSettle();

      expect(location.prompts, 1);
      expect(queries.single.isNearMe, isTrue);
      expect(queries.single.radiusKm, NearbySection.radiusKm);
      expect(find.text('Machko'), findsOneWidget);
      expect(find.text('0.3 km away'), findsOneWidget);
      tester.expectNoOverflow();
    });

    testWidgets('loads straight away when location is already allowed',
        (tester) async {
      LocationService.instance = _FakeLocation(LocationAccess.granted);

      await tester.pumpApp(
          const Scaffold(body: SingleChildScrollView(child: NearbySection())));
      await tester.pumpAndSettle();

      expect(find.text('Machko'), findsOneWidget);
    });

    testWidgets('a permanent refusal offers Settings instead of a dead button',
        (tester) async {
      LocationService.instance = _FakeLocation(LocationAccess.deniedForever);

      await tester.pumpApp(
          const Scaffold(body: SingleChildScrollView(child: NearbySection())));
      await tester.pumpAndSettle();

      expect(find.text('Open Settings'), findsOneWidget);
      expect(find.text('Use my location'), findsNothing);
    });

    for (final locale in const [Locale('ku'), Locale('ar')]) {
      testWidgets('the prompt fits in ${locale.languageCode}', (tester) async {
        LocationService.instance = _FakeLocation(LocationAccess.notDetermined);
        await tester.pumpApp(
          const Scaffold(body: SingleChildScrollView(child: NearbySection())),
          locale: locale,
        );
        await tester.pumpAndSettle();
        tester.expectNoOverflow();
      });
    }
  });

  group('Explore', () {
    Finder chip(String label) => find.descendant(
          of: find.byType(AnimatedContainer),
          matching: find.text(label),
        );

    testWidgets('the Near me chip sorts by distance and toggles back',
        (tester) async {
      LocationService.instance = _FakeLocation(LocationAccess.granted);

      await tester.pumpApp(const ExploreScreen(),
          surfaceSize: const Size(1500, 844));
      await tester.pumpAndSettle();

      await tester.tap(chip('Near me'));
      await tester.pumpAndSettle();
      expect(queries.last.isNearMe, isTrue);
      expect(chip('Nearest'), findsOneWidget, reason: 'the sort chip follows');

      await tester.tap(chip('Near me'));
      await tester.pumpAndSettle();
      expect(queries.last.isNearMe, isFalse);
      expect(queries.last.sort, 'rating');
    });

    testWidgets('arriving from "See all" near you starts sorted by distance',
        (tester) async {
      LocationService.instance = _FakeLocation(LocationAccess.granted);

      await tester.pumpApp(const ExploreScreen(initialNearMe: true));
      await tester.pumpAndSettle();

      expect(queries.last.isNearMe, isTrue);
    });
  });
}

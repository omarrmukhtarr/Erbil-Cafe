import 'package:erbilcafe/app/di/injector.dart';
import 'package:erbilcafe/features/auth/data/repositories/auth_repository.dart';
import 'package:erbilcafe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:erbilcafe/features/cafes/data/models/cafe.dart';
import 'package:erbilcafe/features/cafes/data/repositories/cafe_repository.dart';
import 'package:erbilcafe/features/favorites/data/favorites_repository.dart';
import 'package:erbilcafe/features/home/presentation/screens/home_screen.dart';
import 'package:erbilcafe/features/menu/data/models/menu.dart';
import 'package:erbilcafe/features/menu/data/repositories/menu_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

class _MockCafes extends Mock implements CafeRepository {}

class _MockMenus extends Mock implements MenuRepository {}

class _MockFavorites extends Mock implements FavoritesRepository {}

class _MockAuth extends Mock implements AuthRepository {}

class _FakeCafeQuery extends Fake implements CafeQuery {}

Cafe buildCafe({
  required String id,
  required String name,
  bool featured = false,
  bool openNow = true,
  List<String> amenities = const ['Wi-Fi', 'Outdoor seating', 'Shisha'],
}) =>
    Cafe(
      id: id,
      slug: id,
      name: name,
      description: 'An Italian coffee house on 40m Street.',
      address: '40m Street, Erbil',
      area: '40m',
      lat: 36.2,
      lng: 43.98,
      priceRange: PriceRange.moderate,
      ratingAvg: 4.6,
      reviewCount: 18,
      isFeatured: featured,
      isOpenNow: openNow,
      amenities: [for (final a in amenities) Amenity(key: a, name: a)],
    );

void main() {
  late _MockCafes cafes;
  late _MockMenus menus;
  late _MockAuth auth;

  setUpAll(() => registerFallbackValue(_FakeCafeQuery()));

  setUp(() async {
    await sl.reset();
    cafes = _MockCafes();
    menus = _MockMenus();
    auth = _MockAuth();
    when(() => auth.hasSession).thenAnswer((_) async => false);

    sl
      ..registerSingleton<CafeRepository>(cafes)
      ..registerSingleton<MenuRepository>(menus)
      ..registerSingleton<FavoritesRepository>(_MockFavorites());

    when(() => cafes.list(any())).thenAnswer(
      (_) async => Paginated(items: [
        buildCafe(id: 'machko', name: 'Machko Cafe', featured: true),
        buildCafe(id: 'barbera', name: 'Barbera Cafe'),
      ]),
    );
    when(() => cafes.amenities()).thenAnswer(
      (_) async => const [
        AmenityCount(key: 'wifi', name: 'Wi-Fi', count: 14),
        AmenityCount(key: 'shisha', name: 'Shisha', count: 7),
        AmenityCount(key: 'city_view', name: 'City view', count: 4),
      ],
    );
    when(() => cafes.areas()).thenAnswer(
      (_) async => const [
        AreaCount(area: '40m', count: 5),
        AreaCount(area: 'Ainkawa', count: 3),
      ],
    );
    when(() => menus.popular()).thenAnswer(
      (_) async => const [
        PopularItem(
          item: MenuItem(
            id: 'i1',
            name: 'Espresso Italiano',
            description: '',
            priceIqd: 3000,
            isAvailable: true,
            isPopular: true,
            tags: [],
          ),
          category: 'Hot Coffee',
          cafeId: 'c1',
          cafeSlug: 'barbera-cafe',
          cafeName: 'Barbera Cafe',
          cafeRating: 4.8,
        ),
        // A sold-out item: its "unavailable" chip and its price both have to
        // fit on a 164pt tile, which they did not when they shared a row.
        PopularItem(
          item: MenuItem(
            id: 'i2',
            name: 'Caffe Latte',
            description: '',
            priceIqd: 5000,
            isAvailable: false,
            isPopular: true,
            tags: [],
          ),
          category: 'Hot Coffee',
          cafeId: 'c2',
          cafeSlug: 'alreef-cafe',
          cafeName: 'Alreef Cafe',
          cafeRating: 4.2,
        ),
      ],
    );
  });

  Future<void> pumpHome(WidgetTester tester, {Locale locale = const Locale('en')}) async {
    await tester.pumpApp(
      BlocProvider(
        create: (_) => AuthCubit(auth),
        child: const HomeScreen(),
      ),
      locale: locale,
      // Tall enough to lay every section out at once, so a section that only
      // overflows once it is on screen still fails the test.
      surfaceSize: const Size(390, 2200),
    );
    await tester.pumpAndSettle();
  }

  group('HomeScreen', () {
    testWidgets('shows every section, not just featured and popular',
        (tester) async {
      await pumpHome(tester);

      // The two the page started with…
      expect(find.text('Featured'), findsWidgets);
      expect(find.text('Popular'), findsOneWidget);
      // …and the three that answer a different question about the same
      // catalogue: what kind of place, what is open, and which part of town.
      expect(find.text('Open now'), findsWidgets);
      expect(find.text('Open right now'), findsOneWidget);
      expect(find.text('Browse by area'), findsOneWidget);
      expect(find.text('Ainkawa'), findsOneWidget);
      expect(find.text('3 cafés'), findsOneWidget);
    });

    testWidgets('categories come from the amenities the catalogue has',
        (tester) async {
      await pumpHome(tester);

      expect(find.text('Wi-Fi'), findsWidgets);
      expect(find.text('City view'), findsWidgets);
      verify(() => cafes.amenities()).called(1);
    });

    testWidgets('a popular item carries its price and its café',
        (tester) async {
      await pumpHome(tester);

      expect(find.text('Espresso Italiano'), findsOneWidget);
      expect(find.text('IQD 3,000'), findsOneWidget);
      expect(find.text('Barbera Cafe'), findsWidgets);
    });

    for (final locale in [const Locale('en'), const Locale('ku'), const Locale('ar')]) {
      testWidgets('lays out without overflowing in ${locale.languageCode}',
          (tester) async {
        await pumpHome(tester, locale: locale);
        tester.expectNoOverflow();
      });
    }
  });
}

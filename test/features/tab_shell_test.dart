import 'package:erbilcafe/app/app.dart';
import 'package:erbilcafe/app/di/injector.dart';
import 'package:erbilcafe/app/router/app_router.dart';
import 'package:erbilcafe/core/storage/app_preferences.dart';
import 'package:erbilcafe/features/auth/data/repositories/auth_repository.dart';
import 'package:erbilcafe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:erbilcafe/features/cafes/data/models/cafe.dart';
import 'package:erbilcafe/features/cafes/data/repositories/cafe_repository.dart';
import 'package:erbilcafe/features/cafes/presentation/screens/explore_screen.dart';
import 'package:erbilcafe/features/favorites/data/favorites_repository.dart';
import 'package:erbilcafe/features/home/presentation/screens/home_screen.dart';
import 'package:erbilcafe/features/menu/data/models/menu.dart';
import 'package:erbilcafe/app/theme/app_theme.dart';
import 'package:erbilcafe/features/menu/data/repositories/menu_repository.dart';
import 'package:erbilcafe/l10n/app_localizations.dart';
import 'package:erbilcafe/l10n/kurdish_material_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _MockCafes extends Mock implements CafeRepository {}

class _MockMenus extends Mock implements MenuRepository {}

class _MockFavorites extends Mock implements FavoritesRepository {}

class _MockAuth extends Mock implements AuthRepository {}

class _FakeCafeQuery extends Fake implements CafeQuery {}

Cafe _cafe(String id) => Cafe(
      id: id,
      slug: id,
      name: 'Barbera Cafe',
      description: '',
      address: '',
      area: '40m',
      lat: 36.2,
      lng: 43.98,
      priceRange: PriceRange.moderate,
      ratingAvg: 4.6,
      reviewCount: 12,
      isFeatured: true,
      isOpenNow: true,
      amenities: const [Amenity(key: 'wifi', name: 'Wi-Fi')],
    );

/// The tab shell.
///
/// Widget tests report `defaultTargetPlatform` as Android, so the shell builds
/// its Material bar — real Flutter widgets a finder can tap, rather than the
/// iOS bar's UIKit platform view, which has nothing to hit.
///
/// The five tabs used to share one navigator, which made switching them a
/// route replacement: iOS animated it like a push, and the outgoing screen was
/// disposed — so Home refetched everything each time it came back and Explore
/// forgot what had been typed into it. These tests pin the behaviour that
/// replaced it.
void main() {
  late _MockCafes cafes;
  late _MockMenus menus;
  late _MockAuth auth;

  setUpAll(() => registerFallbackValue(_FakeCafeQuery()));

  setUp(() async {
    await sl.reset();
    SharedPreferences.setMockInitialValues({'has_onboarded': true});

    cafes = _MockCafes();
    menus = _MockMenus();
    auth = _MockAuth();
    when(() => auth.hasSession).thenAnswer((_) async => false);

    when(() => cafes.list(any()))
        .thenAnswer((_) async => Paginated(items: [_cafe('barbera')]));
    when(() => cafes.amenities()).thenAnswer(
      (_) async => const [AmenityCount(key: 'wifi', name: 'Wi-Fi', count: 14)],
    );
    when(() => cafes.areas())
        .thenAnswer((_) async => const [AreaCount(area: '40m', count: 5)]);
    when(() => menus.popular()).thenAnswer((_) async => const <PopularItem>[]);

    sl
      ..registerSingleton<CafeRepository>(cafes)
      ..registerSingleton<MenuRepository>(menus)
      ..registerSingleton<FavoritesRepository>(_MockFavorites())
      ..registerSingleton<AuthCubit>(AuthCubit(auth));
  });

  /// Pumps a bounded number of frames.
  ///
  /// Not `pumpAndSettle`: the loading skeletons shimmer on a repeating
  /// animation, so there is never a frame where nothing is scheduled and
  /// `pumpAndSettle` waits until it times out.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<GoRouter> pumpShell(WidgetTester tester) async {
    final prefs = AppPreferences(await SharedPreferences.getInstance());
    final router = createRouter(authCubit: sl<AuthCubit>(), prefs: prefs);
    await sl<AuthCubit>().restore();

    // Mirrors ErbilCafeApp: the screens read AuthCubit and AppSettings from
    // above the router, so a bare MaterialApp.router is not the real tree.
    await tester.pumpWidget(
      BlocProvider.value(
        value: sl<AuthCubit>(),
        child: AppSettings(
          locale: const Locale('en'),
          themeMode: ThemeMode.light,
          setLocale: (_) async {},
          setThemeMode: (_) async {},
          child: MaterialApp.router(
            routerConfig: router,
            theme: AppTheme.light(),
            locale: const Locale('en'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...KurdishLocalizations.delegates,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
        ),
      ),
    );
    await settle(tester);
    return router;
  }

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    await settle(tester);
  }

  testWidgets('switching tabs keeps each tab alive instead of rebuilding it',
      (tester) async {
    await pumpShell(tester);

    // Categories and popular items are fetched by Home and by nothing else,
    // so they are the honest measure of "did Home run its initState again".
    verify(() => cafes.amenities()).called(1);
    verify(() => menus.popular()).called(1);
    final homeState = tester.state<State<HomeScreen>>(find.byType(HomeScreen));

    await tapTab(tester, 'Explore');
    expect(find.byType(ExploreScreen), findsOneWidget);

    await tapTab(tester, 'Home');

    // Same State object: the tab was kept, not torn down and rebuilt.
    expect(tester.state<State<HomeScreen>>(find.byType(HomeScreen)),
        same(homeState));
    // And so it did not go back to the network for what it already had.
    verifyNever(() => cafes.amenities());
    verifyNever(() => menus.popular());
  });

  testWidgets('a tab keeps what was typed into it', (tester) async {
    await pumpShell(tester);
    await tapTab(tester, 'Explore');

    await tester.enterText(find.byType(TextField).first, 'machko');
    await settle(tester);

    await tapTab(tester, 'Home');
    await tapTab(tester, 'Explore');

    expect(find.text('machko'), findsOneWidget);
  });

  testWidgets('the bar follows the tab the router is on', (tester) async {
    final router = await pumpShell(tester);

    // Home links into Explore with a filter already applied; the bar has to
    // follow, since the destination is another branch entirely.
    router.go(Routes.exploreWith(amenity: 'wifi'));
    await settle(tester);

    expect(find.byType(ExploreScreen), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
  });
}

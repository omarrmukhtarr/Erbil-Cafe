import 'package:erbilcafe/app/di/injector.dart';
import 'package:erbilcafe/core/widgets/app_states.dart';
import 'package:erbilcafe/features/auth/data/models/user.dart';
import 'package:erbilcafe/features/auth/data/repositories/auth_repository.dart';
import 'package:erbilcafe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:erbilcafe/features/cafes/data/models/cafe.dart';
import 'package:erbilcafe/features/favorites/data/favorites_repository.dart';
import 'package:erbilcafe/features/menu/data/models/menu.dart';
import 'package:erbilcafe/features/menu/data/repositories/menu_repository.dart';
import 'package:erbilcafe/features/menu/presentation/screens/menu_screen.dart';
import 'package:erbilcafe/features/profile/presentation/screens/profile_screen.dart';
import 'package:erbilcafe/features/reservations/data/models/reservation.dart';
import 'package:erbilcafe/features/reservations/data/repositories/reservation_repository.dart';
import 'package:erbilcafe/features/reservations/presentation/screens/my_bookings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

class _MockMenus extends Mock implements MenuRepository {}

class _MockReservations extends Mock implements ReservationRepository {}

class _MockFavorites extends Mock implements FavoritesRepository {}

class _MockAuth extends Mock implements AuthRepository {}

Menu buildMenu() => Menu(
      cafeId: 'c1',
      categories: [
        MenuCategory(
          id: 'cat1',
          name: 'Hot Coffee',
          items: const [
            MenuItem(
              id: 'i1',
              name: 'Espresso Italiano',
              description: 'A single shot, classic and intense',
              priceIqd: 3000,
              isAvailable: true,
              isPopular: true,
              tags: [],
            ),
            MenuItem(
              id: 'i2',
              name: 'Caffe Latte',
              description: '',
              priceIqd: 5000,
              isAvailable: false,
              isPopular: false,
              tags: [],
            ),
          ],
        ),
      ],
    );

Reservation buildReservation(ReservationStatus status) => Reservation(
      id: 'r1',
      reference: 'ERB-7A1D02',
      date: DateTime.now().add(const Duration(days: 5)),
      time: '19:30',
      partySize: 4,
      status: status,
      contactName: 'Aram Hama',
      contactPhone: '+9647501234567',
      cafeId: 'c1',
      cafeSlug: 'barbera-cafe',
      cafeName: 'Barbera Cafe',
      createdAt: DateTime.now(),
      declineReason:
          status == ReservationStatus.declined ? 'Fully booked' : null,
    );

void main() {
  late _MockMenus menus;
  late _MockReservations reservations;
  late _MockAuth auth;

  setUp(() async {
    await sl.reset();
    menus = _MockMenus();
    reservations = _MockReservations();
    auth = _MockAuth();
    when(() => auth.hasSession).thenAnswer((_) async => false);

    sl
      ..registerSingleton<MenuRepository>(menus)
      ..registerSingleton<ReservationRepository>(reservations)
      ..registerSingleton<FavoritesRepository>(_MockFavorites())
      ..registerSingleton<AuthRepository>(auth)
      ..registerSingleton<AuthCubit>(AuthCubit(auth));
  });

  tearDown(() => sl.reset());

  group('MenuScreen', () {
    testWidgets('groups items under their category with prices in IQD',
        (tester) async {
      when(() => menus.forCafe(any())).thenAnswer((_) async => buildMenu());

      await tester.pumpApp(const MenuScreen(slug: 'barbera-cafe'));
      await tester.pumpAndSettle();

      expect(find.text('Hot Coffee'), findsOneWidget);
      expect(find.text('Espresso Italiano'), findsOneWidget);
      expect(find.text('IQD 3,000'), findsOneWidget);
    });

    testWidgets('marks an unavailable item instead of hiding it',
        (tester) async {
      when(() => menus.forCafe(any())).thenAnswer((_) async => buildMenu());

      await tester.pumpApp(const MenuScreen(slug: 'barbera-cafe'));
      await tester.pumpAndSettle();

      // The menu should still read as complete.
      expect(find.text('Caffe Latte'), findsOneWidget);
      expect(find.text('Unavailable'), findsOneWidget);
      expect(find.text('IQD 5,000'), findsNothing);
    });

    testWidgets('shows an empty state rather than a blank page',
        (tester) async {
      when(() => menus.forCafe(any())).thenAnswer(
        (_) async => const Menu(cafeId: 'c1', categories: []),
      );

      await tester.pumpApp(const MenuScreen(slug: 'barbera-cafe'));
      await tester.pumpAndSettle();

      expect(find.byType(EmptyView), findsOneWidget);
    });

    testWidgets('lays out in Kurdish without overflowing', (tester) async {
      when(() => menus.forCafe(any())).thenAnswer(
        (_) async => Menu(
          cafeId: 'c1',
          categories: [
            MenuCategory(
              id: 'cat1',
              name: 'قاوەی گەرم',
              items: const [
                MenuItem(
                  id: 'i1',
                  name: 'ئێسپرێسۆی ئیتاڵی',
                  description: 'ئێسپرێسۆی تاک، ڕەسەن و توند',
                  priceIqd: 3000,
                  isAvailable: true,
                  isPopular: true,
                  tags: [],
                ),
              ],
            ),
          ],
        ),
      );

      await tester.pumpApp(
        const MenuScreen(slug: 'barbera-cafe'),
        locale: const Locale('ku'),
      );
      await tester.pumpAndSettle();

      tester.expectNoOverflow();
    });
  });

  group('MyBookingsScreen', () {
    testWidgets('shows the reference and lets an active booking be cancelled',
        (tester) async {
      when(() => reservations.mine(cursor: any(named: 'cursor'))).thenAnswer(
        (_) async => Paginated(items: [
          buildReservation(ReservationStatus.confirmed),
        ]),
      );

      await tester.pumpApp(const MyBookingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Barbera Cafe'), findsOneWidget);
      expect(find.textContaining('ERB-7A1D02'), findsOneWidget);
      expect(find.text('Confirmed'), findsOneWidget);
      expect(find.text('Cancel booking'), findsOneWidget);
    });

    testWidgets('a cancelled booking offers no further cancel action',
        (tester) async {
      when(() => reservations.mine(cursor: any(named: 'cursor'))).thenAnswer(
        (_) async => Paginated(items: [
          buildReservation(ReservationStatus.cancelled),
        ]),
      );

      await tester.pumpApp(const MyBookingsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Cancel booking'), findsNothing);
    });

    testWidgets('a declined booking shows the café’s reason', (tester) async {
      when(() => reservations.mine(cursor: any(named: 'cursor'))).thenAnswer(
        (_) async => Paginated(items: [
          buildReservation(ReservationStatus.declined),
        ]),
      );

      await tester.pumpApp(const MyBookingsScreen());
      await tester.pumpAndSettle();

      // The guest is told why rather than seeing the booking simply vanish.
      expect(find.text('Fully booked'), findsOneWidget);
    });

    testWidgets('empty state instead of a blank list', (tester) async {
      when(() => reservations.mine(cursor: any(named: 'cursor')))
          .thenAnswer((_) async => const Paginated(items: []));

      await tester.pumpApp(const MyBookingsScreen());
      await tester.pumpAndSettle();

      expect(find.byType(EmptyView), findsOneWidget);
    });
  });

  group('ProfileScreen', () {
    testWidgets('offers sign-in to a guest rather than an empty profile',
        (tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: sl<AuthCubit>(),
          child: const ProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sign in required'), findsOneWidget);
    });

    testWidgets('a guest can still change the language and the theme',
        (tester) async {
      // The settings live on this page rather than behind it, and a guest who
      // cannot read the interface needs the language picker most of all.
      await tester.pumpApp(
        BlocProvider.value(
          value: sl<AuthCubit>(),
          child: const ProfileScreen(),
        ),
        surfaceSize: const Size(390, 1200),
      );
      await tester.pumpAndSettle();

      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('کوردی'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('changing the language switches the interface', (tester) async {
      await tester.pumpApp(
        BlocProvider.value(
          value: sl<AuthCubit>(),
          child: const ProfileScreen(),
        ),
        surfaceSize: const Size(390, 1200),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('کوردی'));
      await tester.pumpAndSettle();

      // The page title is the proof: it comes from the localizations, so it
      // only changes if the whole app took the new locale.
      expect(find.text('پرۆفایل'), findsOneWidget);
    });

    testWidgets('shows the signed-in user with their activity counts',
        (tester) async {
      final cubit = sl<AuthCubit>();
      when(() => auth.hasSession).thenAnswer((_) async => true);
      when(() => auth.me()).thenAnswer(
        (_) async => const AppUser(
          id: 'u1',
          name: 'Aram Hama',
          email: 'user@erbilcafe.app',
          role: 'USER',
          locale: 'ku',
          emailVerified: true,
          phoneVerified: false,
          stats: UserStats(reviews: 3, favorites: 2, reservations: 1),
        ),
      );
      await cubit.restore();

      await tester.pumpApp(
        BlocProvider.value(value: cubit, child: const ProfileScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Aram Hama'), findsOneWidget);
      expect(find.text('user@erbilcafe.app'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);

      // Sign out sits under the settings now, so it is below the fold.
      await tester.scrollUntilVisible(find.text('Sign out'), 200);
      expect(find.text('Sign out'), findsOneWidget);
    });
  });
}

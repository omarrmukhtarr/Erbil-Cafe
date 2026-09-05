import 'package:erbilcafe/app/di/injector.dart';
import 'package:erbilcafe/features/auth/data/repositories/auth_repository.dart';
import 'package:erbilcafe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:erbilcafe/features/cafes/data/repositories/cafe_repository.dart';
import 'package:erbilcafe/features/reservations/data/models/reservation.dart';
import 'package:erbilcafe/features/reservations/data/repositories/reservation_repository.dart';
import 'package:erbilcafe/features/reservations/presentation/screens/book_table_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

class _MockReservations extends Mock implements ReservationRepository {}

class _MockCafes extends Mock implements CafeRepository {}

class _MockAuth extends Mock implements AuthRepository {}

Availability availability({
  bool closed = false,
  List<(String, bool)> slots = const [
    ('18:00', true),
    ('18:30', true),
    ('19:00', false),
    ('19:30', true),
  ],
}) =>
    Availability(
      date: '2026-09-20',
      isClosed: closed,
      capacity: 60,
      slots: [
        for (final (time, available) in slots)
          TimeSlot(time: time, available: available, seatsLeft: available ? 40 : 0),
      ],
    );

void main() {
  late _MockReservations reservations;

  setUpAll(() {
    registerFallbackValue(DateTime(2026, 9, 20));
  });

  setUp(() async {
    await sl.reset();
    reservations = _MockReservations();

    final auth = _MockAuth();
    when(() => auth.hasSession).thenAnswer((_) async => true);

    sl
      ..registerSingleton<ReservationRepository>(reservations)
      ..registerSingleton<CafeRepository>(_MockCafes())
      ..registerSingleton<AuthRepository>(auth)
      ..registerSingleton<AuthCubit>(AuthCubit(auth));
  });

  tearDown(() => sl.reset());

  group('BookTableScreen', () {
    testWidgets('lists the slots the café actually has free', (tester) async {
      when(() => reservations.availability(any(),
              date: any(named: 'date'), partySize: any(named: 'partySize')))
          .thenAnswer((_) async => availability());

      await tester.pumpApp(const BookTableScreen(slug: 'barbera-cafe'));
      await tester.pumpAndSettle();

      expect(find.text('18:00'), findsOneWidget);
      expect(find.text('19:30'), findsOneWidget);
      // A full slot stays visible so the café's hours remain legible.
      expect(find.text('19:00'), findsOneWidget);
    });

    testWidgets('cannot submit before a time is chosen', (tester) async {
      when(() => reservations.availability(any(),
              date: any(named: 'date'), partySize: any(named: 'partySize')))
          .thenAnswer((_) async => availability());

      await tester.pumpApp(const BookTableScreen(slug: 'barbera-cafe'));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirm booking'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('enables submit once a slot is picked', (tester) async {
      when(() => reservations.availability(any(),
              date: any(named: 'date'), partySize: any(named: 'partySize')))
          .thenAnswer((_) async => availability());

      await tester.pumpApp(const BookTableScreen(slug: 'barbera-cafe'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('18:30'));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirm booking'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('says so when the café is closed that day', (tester) async {
      when(() => reservations.availability(any(),
              date: any(named: 'date'), partySize: any(named: 'partySize')))
          .thenAnswer((_) async => availability(closed: true));

      await tester.pumpApp(const BookTableScreen(slug: 'barbera-cafe'));
      await tester.pumpAndSettle();

      expect(find.text('The café is closed that day'), findsOneWidget);
    });

    testWidgets('says so when every slot is taken', (tester) async {
      when(() => reservations.availability(any(),
              date: any(named: 'date'), partySize: any(named: 'partySize')))
          .thenAnswer((_) async => availability(
                slots: const [('18:00', false), ('18:30', false)],
              ));

      await tester.pumpApp(const BookTableScreen(slug: 'barbera-cafe'));
      await tester.pumpAndSettle();

      expect(find.text('Fully booked'), findsOneWidget);
    });

    testWidgets('changing the party size re-checks availability',
        (tester) async {
      when(() => reservations.availability(any(),
              date: any(named: 'date'), partySize: any(named: 'partySize')))
          .thenAnswer((_) async => availability());

      await tester.pumpApp(const BookTableScreen(slug: 'barbera-cafe'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('6'));
      await tester.pumpAndSettle();

      // Capacity depends on party size, so the slots must be refetched.
      verify(() => reservations.availability(any(),
          date: any(named: 'date'), partySize: 6)).called(1);
    });

    testWidgets('picking a slot then changing party size clears the choice',
        (tester) async {
      when(() => reservations.availability(any(),
              date: any(named: 'date'), partySize: any(named: 'partySize')))
          .thenAnswer((_) async => availability());

      await tester.pumpApp(const BookTableScreen(slug: 'barbera-cafe'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('18:30'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('4'));
      await tester.pumpAndSettle();

      // Otherwise the form could submit a time that is no longer offered.
      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirm booking'),
      );
      expect(button.onPressed, isNull);
    });
  });
}

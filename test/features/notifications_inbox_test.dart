import 'package:erbilcafe/app/di/injector.dart';
import 'package:erbilcafe/app/router/app_router.dart';
import 'package:erbilcafe/features/notifications/data/app_notification.dart';
import 'package:erbilcafe/features/notifications/data/notification_repository.dart';
import 'package:erbilcafe/features/notifications/data/unread_notifications.dart';
import 'package:erbilcafe/features/notifications/presentation/notification_target.dart';
import 'package:erbilcafe/features/notifications/presentation/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

class _MockNotifications extends Mock implements NotificationRepository {}

AppNotification _notification(String id,
        {bool read = false, Map<String, dynamic> data = const {}}) =>
    AppNotification(
      id: id,
      type: 'RESERVATION_CONFIRMED',
      title: 'Your booking is confirmed',
      body: 'Your table on 2026-09-20 at 20:00 is confirmed.',
      data: data,
      readAt: read ? DateTime(2026, 9, 16) : null,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    );

void main() {
  group('routeForNotification', () {
    test('a booking opens the bookings list', () {
      expect(routeForNotification({'reservationId': 'r1', 'cafeId': 'c1'}),
          Routes.bookings);
    });

    test('a café opens by slug, or by id for older notifications', () {
      expect(routeForNotification({'cafeSlug': 'barbera'}),
          Routes.cafe('barbera'));
      expect(routeForNotification({'cafeId': 'c1'}), Routes.cafe('c1'));
    });

    test('a notification about nothing opens nothing', () {
      expect(routeForNotification(const {}), isNull);
    });
  });

  group('Inbox', () {
    late _MockNotifications repository;

    setUp(() async {
      await sl.reset();
      repository = _MockNotifications();
      when(() => repository.markRead(any())).thenAnswer((_) async {});
      when(() => repository.markAllRead()).thenAnswer((_) async {});
      sl.registerSingleton<NotificationRepository>(repository);
      UnreadNotifications.instance.value = 0;
    });

    tearDown(() => sl.reset());

    testWidgets('lists notifications and tells the badge how many are unread',
        (tester) async {
      when(() => repository.inbox(cursor: any(named: 'cursor'))).thenAnswer(
        (_) async => NotificationPage(
          items: [_notification('n1'), _notification('n2', read: true)],
          unreadCount: 1,
        ),
      );

      await tester.pumpApp(const NotificationsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Your booking is confirmed'), findsNWidgets(2));
      expect(find.text('2 hours ago'), findsNWidgets(2));
      expect(UnreadNotifications.instance.value, 1);
      expect(find.text('Mark all read'), findsOneWidget);
    });

    testWidgets('mark all read clears the badge at once', (tester) async {
      when(() => repository.inbox(cursor: any(named: 'cursor'))).thenAnswer(
        (_) async => NotificationPage(
          items: [_notification('n1'), _notification('n2')],
          unreadCount: 2,
        ),
      );

      await tester.pumpApp(const NotificationsScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();

      expect(UnreadNotifications.instance.value, 0);
      expect(find.text('Mark all read'), findsNothing);
      verify(() => repository.markAllRead()).called(1);
    });

    testWidgets('tapping an unread notification marks it read', (tester) async {
      when(() => repository.inbox(cursor: any(named: 'cursor'))).thenAnswer(
        (_) async =>
            NotificationPage(items: [_notification('n1')], unreadCount: 1),
      );

      await tester.pumpApp(const NotificationsScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Your booking is confirmed'));
      await tester.pump();

      expect(UnreadNotifications.instance.value, 0);
      verify(() => repository.markRead('n1')).called(1);
    });

    testWidgets('an empty inbox says what will arrive there', (tester) async {
      when(() => repository.inbox(cursor: any(named: 'cursor'))).thenAnswer(
        (_) async => const NotificationPage(items: [], unreadCount: 0),
      );

      await tester.pumpApp(const NotificationsScreen());
      await tester.pumpAndSettle();

      expect(find.text('No notifications'), findsOneWidget);
    });

    for (final locale in const [Locale('ku'), Locale('ar')]) {
      testWidgets('lays out in ${locale.languageCode}', (tester) async {
        when(() => repository.inbox(cursor: any(named: 'cursor'))).thenAnswer(
          (_) async =>
              NotificationPage(items: [_notification('n1')], unreadCount: 1),
        );
        await tester.pumpApp(const NotificationsScreen(), locale: locale);
        await tester.pumpAndSettle();
        tester.expectNoOverflow();
      });
    }
  });
}

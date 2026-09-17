import 'package:erbilcafe/app/di/injector.dart';
import 'package:erbilcafe/core/error/failure.dart';
import 'package:erbilcafe/features/auth/data/models/user.dart';
import 'package:erbilcafe/features/auth/data/repositories/auth_repository.dart';
import 'package:erbilcafe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:erbilcafe/features/auth/presentation/screens/reset_password_screen.dart';
import 'package:erbilcafe/features/cafes/data/models/cafe.dart';
import 'package:erbilcafe/features/notifications/data/push_service.dart';
import 'package:erbilcafe/features/profile/presentation/screens/verify_email_screen.dart';
import 'package:erbilcafe/features/reviews/data/models/review.dart';
import 'package:erbilcafe/features/reviews/data/repositories/review_repository.dart';
import 'package:erbilcafe/features/reviews/presentation/screens/my_reviews_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

class _MockAuth extends Mock implements AuthRepository {}

class _MockReviews extends Mock implements ReviewRepository {}

class _MockPush extends Mock implements PushService {}

const _unverified = AppUser(
  id: 'u1',
  name: 'Aram Hama',
  email: 'aram@example.com',
  role: 'USER',
  locale: 'en',
  emailVerified: false,
  phoneVerified: false,
);

void main() {
  late _MockAuth auth;

  setUp(() async {
    await sl.reset();
    auth = _MockAuth();
    final push = _MockPush();
    when(() => push.registerDevice(locale: any(named: 'locale')))
        .thenAnswer((_) async {});
    when(() => push.unregisterDevice()).thenAnswer((_) async {});
    sl
      ..registerSingleton<AuthRepository>(auth)
      ..registerSingleton<PushService>(push);
  });

  tearDown(() => sl.reset());

  test('a refreshed profile with the email now verified is a new state', () {
    // Equality used to ignore the flag, so the cubit dropped the update.
    expect(
      _unverified,
      isNot(equals(const AppUser(
        id: 'u1',
        name: 'Aram Hama',
        email: 'aram@example.com',
        role: 'USER',
        locale: 'en',
        emailVerified: true,
        phoneVerified: false,
      ))),
    );
  });

  group('Reset password', () {
    Future<GoRouter> pumpReset(WidgetTester tester, AuthCubit cubit) async {
      final router = GoRouter(
        initialLocation: '/reset',
        routes: [
          GoRoute(path: '/', builder: (_, __) => const Text('HOME')),
          GoRoute(path: '/sign-in', builder: (_, __) => const Text('SIGN IN')),
          GoRoute(
            path: '/reset',
            builder: (_, __) =>
                const ResetPasswordScreen(email: 'aram@example.com'),
          ),
        ],
      );
      await tester.pumpApp(
        BlocProvider.value(
          value: cubit,
          child: Builder(builder: (_) => const SizedBox()),
        ),
      );
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp.router(
            routerConfig: router,
            localizationsDelegates:
                (tester.widget<MaterialApp>(find.byType(MaterialApp)))
                    .localizationsDelegates,
            supportedLocales: const [Locale('en')],
          ),
        ),
      );
      await tester.pumpAndSettle();
      return router;
    }

    testWidgets('resets with the code, then signs straight in', (tester) async {
      when(() => auth.resetPassword(
            identifier: 'aram@example.com',
            code: '123456',
            newPassword: 'newpass456',
          )).thenAnswer((_) async {});
      when(() => auth.login(email: 'aram@example.com', password: 'newpass456'))
          .thenAnswer((_) async => _unverified);

      await pumpReset(tester, AuthCubit(auth));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '123456');
      await tester.enterText(fields.at(1), 'newpass456');
      await tester.enterText(fields.at(2), 'newpass456');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Change password'));
      await tester.pumpAndSettle();

      verify(() => auth.resetPassword(
            identifier: 'aram@example.com',
            code: '123456',
            newPassword: 'newpass456',
          )).called(1);
      expect(find.text('HOME'), findsOneWidget);
    });

    testWidgets('an incomplete code is caught before anything is sent',
        (tester) async {
      await pumpReset(tester, AuthCubit(auth));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), '123');
      await tester.enterText(fields.at(1), 'newpass456');
      await tester.enterText(fields.at(2), 'newpass456');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Change password'));
      await tester.pumpAndSettle();

      expect(find.text('Enter all 6 digits of the code.'), findsOneWidget);
      verifyNever(() => auth.resetPassword(
            identifier: any(named: 'identifier'),
            code: any(named: 'code'),
            newPassword: any(named: 'newPassword'),
          ));
    });
  });

  group('Verify email', () {
    testWidgets('sends a code, verifies it and refreshes the profile',
        (tester) async {
      when(() => auth.hasSession).thenAnswer((_) async => true);
      when(() => auth.cachedUser()).thenAnswer((_) async => _unverified);
      when(() => auth.me()).thenAnswer((_) async => _unverified);
      final cubit = AuthCubit(auth);
      await cubit.restore();

      when(() => auth.requestOtp('aram@example.com', purpose: 'EMAIL_VERIFY'))
          .thenAnswer((_) async => null);
      when(() => auth.verifyOtp('aram@example.com', '654321',
          purpose: 'EMAIL_VERIFY')).thenAnswer((_) async {});

      await tester.pumpApp(
          BlocProvider.value(value: cubit, child: const VerifyEmailScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send code'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '654321');
      await tester.pump();

      verify(() => auth.verifyOtp('aram@example.com', '654321',
          purpose: 'EMAIL_VERIFY')).called(1);
      // Clear the resend countdown.
      await tester.pump(const Duration(seconds: 61));
    });
  });

  group('My reviews', () {
    testWidgets('lists each review with its café, and deletes one',
        (tester) async {
      final reviews = _MockReviews();
      sl.registerSingleton<ReviewRepository>(reviews);
      final review = Review(
        id: 'r1',
        rating: 4,
        comment: 'Lovely rooftop.',
        images: const [],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        authorId: 'u1',
        authorName: 'Aram',
        status: 'APPROVED',
        cafe: const ReviewCafe(id: 'c1', slug: 'alreef', name: 'Alreef Cafe'),
      );
      when(() => reviews.mine(
              cursor: any(named: 'cursor'), cafeId: any(named: 'cafeId')))
          .thenAnswer((_) async => Paginated<Review>(items: [review]));
      when(() => reviews.delete('r1')).thenAnswer((_) async {});

      await tester.pumpApp(const MyReviewsScreen());
      await tester.pumpAndSettle();

      expect(find.text('Alreef Cafe'), findsOneWidget);
      expect(find.text('Lovely rooftop.'), findsOneWidget);
      expect(find.text('2 days ago'), findsOneWidget);

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
      await tester.pumpAndSettle();

      verify(() => reviews.delete('r1')).called(1);
      expect(find.text('Lovely rooftop.'), findsNothing);
      tester.expectNoOverflow();
    });

    testWidgets('a failed delete puts the review back', (tester) async {
      final reviews = _MockReviews();
      sl.registerSingleton<ReviewRepository>(reviews);
      final review = Review(
        id: 'r1',
        rating: 4,
        images: const [],
        createdAt: DateTime.now(),
        authorId: 'u1',
        authorName: 'Aram',
        cafe: const ReviewCafe(id: 'c1', slug: 'alreef', name: 'Alreef Cafe'),
      );
      when(() => reviews.mine(
              cursor: any(named: 'cursor'), cafeId: any(named: 'cafeId')))
          .thenAnswer((_) async => Paginated<Review>(items: [review]));
      when(() => reviews.delete('r1')).thenThrow(const NetworkFailure());

      await tester.pumpApp(const MyReviewsScreen());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete').last);
      await tester.pumpAndSettle();

      expect(find.text('Alreef Cafe'), findsOneWidget);
    });
  });
}

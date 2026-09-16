import 'package:erbilcafe/app/di/injector.dart';
import 'package:erbilcafe/core/error/failure.dart';
import 'package:erbilcafe/features/auth/data/models/user.dart';
import 'package:erbilcafe/features/auth/data/repositories/auth_repository.dart';
import 'package:erbilcafe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:erbilcafe/features/notifications/data/push_service.dart';
import 'package:erbilcafe/features/profile/presentation/screens/change_password_screen.dart';
import 'package:erbilcafe/features/profile/presentation/screens/help_screen.dart';
import 'package:erbilcafe/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/pump_app.dart';

class _MockAuth extends Mock implements AuthRepository {}

class _MockPush extends Mock implements PushService {}

const _user = AppUser(
  id: 'u1',
  name: 'Aram Hama',
  email: 'aram@example.com',
  role: 'USER',
  locale: 'en',
  emailVerified: true,
  phoneVerified: false,
);

void main() {
  late _MockAuth auth;

  setUp(() async {
    await sl.reset();
    auth = _MockAuth();
    final push = _MockPush();
    when(() => push.unregisterDevice()).thenAnswer((_) async {});
    when(() => push.registerDevice(locale: any(named: 'locale')))
        .thenAnswer((_) async {});
    when(() => auth.logout()).thenAnswer((_) async {});
    sl.registerSingleton<PushService>(push);
  });

  tearDown(() => sl.reset());

  Future<AuthCubit> signedIn() async {
    when(() => auth.hasSession).thenAnswer((_) async => true);
    when(() => auth.cachedUser()).thenAnswer((_) async => _user);
    when(() => auth.me()).thenAnswer((_) async => _user);
    final cubit = AuthCubit(auth);
    // Restoring from a saved profile emits synchronously after the storage
    // reads; the background refresh is not awaited, and `pumpEventQueue`
    // would never return inside a widget test's fake clock.
    await cubit.restore();
    return cubit;
  }

  group('Help', () {
    for (final locale in const [Locale('en'), Locale('ku'), Locale('ar')]) {
      testWidgets('lays out and opens an answer in ${locale.languageCode}',
          (tester) async {
        await tester.pumpApp(const HelpScreen(), locale: locale);
        await tester.pumpAndSettle();

        // Answers start closed; tapping the first question opens it.
        final firstQuestion = find.byIcon(Icons.search_rounded);
        await tester.tap(firstQuestion);
        await tester.pumpAndSettle();

        final opened = tester
            .widgetList<Text>(find.byType(Text))
            .where((t) => (t.data ?? '').length > 120);
        expect(opened, isNotEmpty, reason: 'a long answer should be showing');
        tester.expectNoOverflow();
      });
    }
  });

  group('Profile settings', () {
    testWidgets('offers help, legal pages and the cache to a guest',
        (tester) async {
      when(() => auth.hasSession).thenAnswer((_) async => false);
      final cubit = AuthCubit(auth);
      await cubit.restore();

      await tester.pumpApp(
        BlocProvider.value(value: cubit, child: const ProfileScreen()),
        surfaceSize: const Size(390, 2400),
      );
      await tester.pumpAndSettle();

      for (final label in [
        'Help & FAQ',
        'Contact support',
        'Report a problem',
        'Terms of service',
        'Privacy policy',
        'Open-source licences',
        'Clear cached photos and data',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
      // Account actions need an account.
      expect(find.text('Edit profile'), findsNothing);
      tester.expectNoOverflow();
    });

    testWidgets('a signed-in user can reach edit profile and change password',
        (tester) async {
      final cubit = await signedIn();

      await tester.pumpApp(
        BlocProvider.value(value: cubit, child: const ProfileScreen()),
        surfaceSize: const Size(390, 2600),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('Change password'), findsOneWidget);
      tester.expectNoOverflow();
    });
  });

  group('Change password', () {
    Future<void> pumpForm(WidgetTester tester, AuthCubit cubit) async {
      await tester.pumpApp(
        BlocProvider.value(value: cubit, child: const ChangePasswordScreen()),
      );
      await tester.pumpAndSettle();
    }

    Future<void> fill(WidgetTester tester, String current, String next,
        String confirm) async {
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), current);
      await tester.enterText(fields.at(1), next);
      await tester.enterText(fields.at(2), confirm);
      await tester.tap(find.widgetWithText(ElevatedButton, 'Change password'));
      await tester.pumpAndSettle();
    }

    testWidgets('refuses a new password that is the current one',
        (tester) async {
      await pumpForm(tester, await signedIn());
      await fill(tester, 'oldpass123', 'oldpass123', 'oldpass123');

      expect(find.text('Choose a password different from your current one.'),
          findsOneWidget);
      verifyNever(() => auth.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          ));
    });

    testWidgets('refuses a confirmation that does not match', (tester) async {
      await pumpForm(tester, await signedIn());
      await fill(tester, 'oldpass123', 'newpass456', 'newpass457');

      verifyNever(() => auth.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          ));
    });
  });

  group('AuthCubit.changePassword', () {
    test('signs straight back in, because the API revoked this session too',
        () async {
      final cubit = await signedIn();
      when(() => auth.changePassword(
            currentPassword: 'oldpass123',
            newPassword: 'newpass456',
          )).thenAnswer((_) async {});
      when(() => auth.login(email: 'aram@example.com', password: 'newpass456'))
          .thenAnswer((_) async => _user);

      await cubit.changePassword(
        currentPassword: 'oldpass123',
        newPassword: 'newpass456',
      );

      verify(() =>
              auth.login(email: 'aram@example.com', password: 'newpass456'))
          .called(1);
      expect(cubit.state.isAuthenticated, isTrue);
    });

    test('a wrong current password is reported and changes nothing', () async {
      final cubit = await signedIn();
      when(() => auth.changePassword(
                currentPassword: 'wrong',
                newPassword: 'newpass456',
              ))
          .thenThrow(
              const UnauthorizedFailure('Your current password is incorrect'));

      await expectLater(
        cubit.changePassword(
            currentPassword: 'wrong', newPassword: 'newpass456'),
        throwsA(isA<UnauthorizedFailure>()),
      );
      expect(cubit.state.isAuthenticated, isTrue);
      verifyNever(() => auth.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ));
    });
  });
}

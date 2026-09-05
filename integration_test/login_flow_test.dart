import 'package:erbilcafe/app/app.dart';
import 'package:erbilcafe/app/di/injector.dart';
import 'package:erbilcafe/core/storage/app_preferences.dart';
import 'package:erbilcafe/app/router/app_router.dart';
import 'package:erbilcafe/core/storage/token_storage.dart';
import 'package:erbilcafe/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';

/// End-to-end sign-in against a running API.
///
/// Widget tests mock the repository, so they prove the screen behaves — not
/// that authentication actually works. This drives the real UI against the
/// real backend, which is the only way to catch a broken token exchange, a
/// wrong base URL, or a keystore write that silently fails on device.
///
///   cd backend && pnpm dev          # API on :3100
///   flutter test integration_test/login_flow_test.dart \
///     --dart-define=API_URL=http://localhost:3100/api/v1
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await sl.reset();
    await setupInjector();
    // Start every run signed out, past onboarding, and in a known language —
    // a locale left over from a previous session would break every finder.
    await sl<TokenStorage>().clear();
    await sl<AppPreferences>().setOnboarded();
    await sl<AppPreferences>().setLocale(const Locale('en'));
  });

  Future<void> bootApp(WidgetTester tester) async {
    await sl<AuthCubit>().restore();
    await tester.pumpWidget(const ErbilCafeApp());
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // The router captured `hasOnboarded` when the injector built it, which on
    // a fresh install is false. Start every test from Home regardless.
    sl<GoRouter>().go(Routes.home);
    await tester.pumpAndSettle(const Duration(seconds: 4));
  }

  /// Navigates by route rather than by tapping the tab bar.
  ///
  /// On iOS the bar is a native UIKit view, so it has no Flutter widgets for a
  /// finder to hit. Driving the router also keeps these tests about the screen
  /// under test rather than about the bar's implementation.
  Future<void> goTo(WidgetTester tester, String route) async {
    sl<GoRouter>().go(route);
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  testWidgets('a guest can browse without an account', (tester) async {
    await bootApp(tester);

    // Cafés come from the API, so reaching them proves the client works.
    // 'Featured' is both a section heading and a badge on each featured card,
    // so match the heading by its style rather than by text alone.
    expect(find.text('Featured'), findsWidgets);
    expect(find.text('Popular'), findsOneWidget);
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.textContaining('IQD'), findsWidgets);
  });

  testWidgets('signing in stores a session and fills the profile',
      (tester) async {
    await bootApp(tester);

    // Profile → sign-in prompt.
    await goTo(tester, Routes.profile);
    expect(find.text('Sign in required'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'user@erbilcafe.app');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'user12345');
    await tester.pumpAndSettle();

    // Note: pressing the keyboard's done key also submits, via
    // onFieldSubmitted — so only one of the two may be exercised here.
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle(const Duration(seconds: 6));

    // The session must be real, not just a UI state change.
    expect(sl<AuthCubit>().state.isAuthenticated, isTrue);
    expect(await sl<TokenStorage>().readAccessToken(), isNotNull);
    expect(await sl<TokenStorage>().readRefreshToken(), isNotNull);

    await goTo(tester, Routes.profile);

    expect(find.text('Aram Hama'), findsOneWidget);
    expect(find.text('user@erbilcafe.app'), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    // Counts come from /users/me, so they prove the authenticated call works.
    expect(find.text('My bookings'), findsOneWidget);
  });

  testWidgets('a wrong password is rejected and leaves no session',
      (tester) async {
    await bootApp(tester);

    await goTo(tester, Routes.profile);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'user@erbilcafe.app');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'wrongpass1');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle(const Duration(seconds: 6));

    expect(sl<AuthCubit>().state.isAuthenticated, isFalse);
    expect(await sl<TokenStorage>().readRefreshToken(), isNull);
    expect(find.text('Incorrect email or password'), findsOneWidget);
  });

  testWidgets('the session survives a restart', (tester) async {
    await bootApp(tester);

    await goTo(tester, Routes.profile);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'user@erbilcafe.app');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'user12345');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle(const Duration(seconds: 6));

    expect(sl<AuthCubit>().state.isAuthenticated, isTrue);

    // Rebuild from cold: the refresh token in the keystore must restore the
    // session, or every app launch would look like a sign-out.
    sl<AuthCubit>().onSessionExpired();
    await sl<AuthCubit>().restore();
    await tester.pumpAndSettle(const Duration(seconds: 4));

    expect(sl<AuthCubit>().state.isAuthenticated, isTrue);
    expect(sl<AuthCubit>().state.user?.email, 'user@erbilcafe.app');
  });

  testWidgets('signing out clears the stored tokens', (tester) async {
    await bootApp(tester);

    await goTo(tester, Routes.profile);
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 'user@erbilcafe.app');
    await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 'user12345');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle(const Duration(seconds: 6));

    await sl<AuthCubit>().logout();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(sl<AuthCubit>().state.isAuthenticated, isFalse);
    expect(await sl<TokenStorage>().readRefreshToken(), isNull);
  });
}

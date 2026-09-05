import 'dart:async';

import 'package:cupertino_native_better/cupertino_native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/storage/app_preferences.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/sign_in_screen.dart';
import '../../features/auth/presentation/screens/sign_up_screen.dart';
import '../../features/cafes/presentation/screens/cafe_detail_screen.dart';
import '../../features/cafes/presentation/screens/explore_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/widgets/app_shell.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/menu/presentation/screens/menu_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/reservations/presentation/screens/book_table_screen.dart';
import '../../features/reservations/presentation/screens/my_bookings_screen.dart';
import '../../features/reviews/presentation/screens/write_review_screen.dart';

abstract final class Routes {
  static const onboarding = '/onboarding';
  static const signIn = '/sign-in';
  static const signUp = '/sign-up';
  static const otp = '/otp';
  static const forgotPassword = '/forgot-password';

  static const home = '/';
  static const explore = '/explore';
  static const map = '/map';
  static const favorites = '/favorites';
  static const profile = '/profile';

  static const settings = '/settings';
  static const bookings = '/bookings';

  static String cafe(String slug) => '/cafe/$slug';
  static String menu(String slug) => '/cafe/$slug/menu';
  static String book(String slug) => '/cafe/$slug/book';
  static String review(String slug) => '/cafe/$slug/review';
}

/// Tabs that keep their own navigation stack.
final _shellKey = GlobalKey<NavigatorState>();
final _rootKey = GlobalKey<NavigatorState>();

GoRouter createRouter({
  required AuthCubit authCubit,
  required AppPreferences prefs,
}) {
  // Debug-only entry point override, so a screen can be opened directly
  // during development: flutter run --dart-define=START_ROUTE=/map
  const startRouteOverride = String.fromEnvironment('START_ROUTE');
  final initialLocation = kDebugMode && startRouteOverride.isNotEmpty
      ? startRouteOverride
      : (prefs.hasOnboarded ? Routes.home : Routes.onboarding);

  return GoRouter(
    navigatorKey: _rootKey,
    // Lets the native tab bar know when a sheet or dialog is up, so it can
    // drop its platform view rather than bleeding through the scrim.
    observers: [CNTabBarRouteObserver()],
    initialLocation: initialLocation,

    // Re-evaluates redirects whenever the session changes, so signing out from
    // any screen bounces to sign-in without each screen listening itself.
    refreshListenable: _CubitRefresh(authCubit.stream),

    redirect: (context, state) {
      final auth = authCubit.state;
      final path = state.matchedLocation;

      // Hold every route until the session has been restored, otherwise the
      // first frame can redirect a signed-in user to sign-in.
      if (auth.status == AuthStatus.unknown) return null;

      const authRoutes = {
        Routes.signIn,
        Routes.signUp,
        Routes.otp,
        Routes.forgotPassword,
      };

      // Browsing is open to guests; only these routes require an account.
      const protected = {Routes.favorites, Routes.bookings, Routes.settings};
      final needsAuth = protected.contains(path) ||
          path.endsWith('/book') ||
          path.endsWith('/review');

      if (needsAuth && !auth.isAuthenticated) {
        return '${Routes.signIn}?from=$path';
      }

      // A signed-in user has no business on the sign-in screen.
      if (auth.isAuthenticated && authRoutes.contains(path)) {
        return Routes.home;
      }

      return null;
    },

    routes: [
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: Routes.signIn,
        builder: (context, state) =>
            SignInScreen(redirectTo: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: Routes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: Routes.otp,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>? ?? const {};
          return OtpScreen(
            identifier: extra['identifier'] as String? ?? '',
            devCode: extra['devCode'] as String?,
          );
        },
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ─── Tabs ─────────────────────────────────────────────────────
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) =>
            AppShell(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(
            path: Routes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: Routes.explore,
            builder: (context, state) => const ExploreScreen(),
          ),
          GoRoute(
            path: Routes.map,
            builder: (context, state) => const MapScreen(),
          ),
          GoRoute(
            path: Routes.favorites,
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: Routes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ─── Full-screen ──────────────────────────────────────────────
      GoRoute(
        path: '/cafe/:slug',
        parentNavigatorKey: _rootKey,
        builder: (context, state) =>
            CafeDetailScreen(slug: state.pathParameters['slug']!),
        routes: [
          GoRoute(
            path: 'menu',
            parentNavigatorKey: _rootKey,
            builder: (context, state) =>
                MenuScreen(slug: state.pathParameters['slug']!),
          ),
          GoRoute(
            path: 'book',
            parentNavigatorKey: _rootKey,
            builder: (context, state) =>
                BookTableScreen(slug: state.pathParameters['slug']!),
          ),
          GoRoute(
            path: 'review',
            parentNavigatorKey: _rootKey,
            builder: (context, state) =>
                WriteReviewScreen(slug: state.pathParameters['slug']!),
          ),
        ],
      ),
      GoRoute(
        path: Routes.bookings,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}

/// Bridges a bloc stream to a [Listenable] for go_router's refreshListenable.
class _CubitRefresh extends ChangeNotifier {
  _CubitRefresh(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

/// Convenience for reading the session inside widgets.
extension AuthContext on BuildContext {
  AuthState get auth => read<AuthCubit>().state;
  bool get isSignedIn => auth.isAuthenticated;
}

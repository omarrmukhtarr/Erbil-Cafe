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
import '../../features/cafes/data/models/cafe.dart';
import '../../features/cafes/presentation/screens/cafe_detail_screen.dart';
import '../../features/cafes/presentation/screens/explore_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/home/presentation/widgets/app_shell.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/menu/presentation/screens/menu_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/screens/change_password_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/help_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
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

  static const bookings = '/bookings';

  static const editProfile = '/settings/profile';
  static const changePassword = '/settings/password';
  static const help = '/help';

  /// Explore, opened with a filter already applied.
  ///
  /// The home screen's category strip and area tiles hand off here rather than
  /// each growing their own listing screen — one filtered list, reachable from
  /// several places.
  static String exploreWith({
    String? amenity,
    String? area,
    bool openNow = false,
    String? sort,
  }) {
    final params = <String, String>{
      if (amenity != null) 'amenity': amenity,
      if (area != null) 'area': area,
      if (openNow) 'openNow': '1',
      if (sort != null) 'sort': sort,
    };
    if (params.isEmpty) return explore;
    return Uri(path: explore, queryParameters: params).toString();
  }

  static String cafe(String slug) => '/cafe/$slug';
  static String menu(String slug) => '/cafe/$slug/menu';
  static String book(String slug) => '/cafe/$slug/book';
  static String review(String slug) => '/cafe/$slug/review';
}

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
      const protected = {
        Routes.favorites,
        Routes.bookings,
        Routes.editProfile,
        Routes.changePassword,
      };
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
      //
      // One navigator per tab, held side by side in an IndexedStack.
      //
      // A plain ShellRoute put all five tabs in a *single* navigator, which
      // made switching tabs a route replacement: iOS gave it the standard page
      // transition, so tabs slid in over one another like a push, and every
      // screen was torn down and rebuilt on the way out. Home refetched five
      // endpoints each time it was returned to, Explore forgot its search and
      // filters, and the map rebuilt its markers and clustering from scratch.
      //
      // A branch keeps its navigator, its widget state, its cubits and its
      // scroll offset for as long as the app runs, and the swap between them
      // is a paint, not an animation. Branches are built lazily, so a tab
      // nobody opens — the map, with its platform view — costs nothing.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.explore,
                builder: (context, state) {
                  final params = state.uri.queryParameters;
                  return ExploreScreen(
                    // Keyed on the filter so arriving from a different category
                    // rebuilds the screen instead of reusing the previous state.
                    key: ValueKey(state.uri.query),
                    initialAmenity: params['amenity'],
                    initialArea: params['area'],
                    initialOpenNow: params['openNow'] == '1',
                    initialSort: params['sort'],
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.map,
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.favorites,
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ─── Full-screen ──────────────────────────────────────────────
      GoRoute(
        path: '/cafe/:slug',
        parentNavigatorKey: _rootKey,
        builder: (context, state) => CafeDetailScreen(
          slug: state.pathParameters['slug']!,
          // The card that was tapped, when there was one — lets the page
          // draw its header on the first frame. A deep link or a notification
          // has no card, and the page loads as before.
          preview: state.extra is Cafe ? state.extra! as Cafe : null,
        ),
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
        path: Routes.editProfile,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: Routes.changePassword,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      // Open to guests: someone who cannot sign in is exactly who needs help.
      GoRoute(
        path: Routes.help,
        parentNavigatorKey: _rootKey,
        builder: (context, state) => const HelpScreen(),
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

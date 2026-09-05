import 'dart:ui';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/network/api_client.dart';
import '../../core/network/auth_interceptor.dart';
import '../../core/storage/app_preferences.dart';
import '../../core/storage/token_storage.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/cafes/data/repositories/cafe_repository.dart';
import '../../features/favorites/data/favorites_repository.dart';
import '../../features/menu/data/repositories/menu_repository.dart';
import '../../features/reservations/data/repositories/reservation_repository.dart';
import '../../features/reviews/data/repositories/review_repository.dart';
import '../router/app_router.dart';

final sl = GetIt.instance;

/// Languages the app ships translations for.
const supportedLanguages = {'ku', 'ar', 'en'};

/// Wires up storage, networking and repositories.
///
/// Must complete before `runApp`, because the router's redirect reads the
/// session on the very first frame.
Future<void> setupInjector() async {
  // ─── Storage ────────────────────────────────────────────────────────
  final prefs = await SharedPreferences.getInstance();
  sl
    ..registerSingleton<AppPreferences>(AppPreferences(prefs))
    ..registerSingleton<TokenStorage>(
      TokenStorage(
        const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        ),
      ),
    );

  // ─── Networking ─────────────────────────────────────────────────────
  // Follow the device language when the user has not chosen one, so café and
  // menu text arrives in the same language as the app's own strings. Falling
  // back to a hardcoded 'ku' here would show Kurdish content in an English UI.
  final stored = sl<AppPreferences>().locale?.languageCode;
  final device = PlatformDispatcher.instance.locale.languageCode;
  final locale = stored ?? (supportedLanguages.contains(device) ? device : 'ku');

  final dio = ApiClient.createDio(locale: locale == 'ku' ? 'ckb' : locale);

  // A second client without the auth interceptor, so refreshing a token cannot
  // recurse into another refresh.
  final refreshDio = ApiClient.createDio(locale: locale);

  final apiClient = ApiClient(dio);
  sl.registerSingleton<ApiClient>(apiClient);

  // ─── Repositories ───────────────────────────────────────────────────
  sl
    ..registerSingleton<AuthRepository>(
      AuthRepository(apiClient, sl<TokenStorage>()),
    )
    ..registerSingleton<CafeRepository>(CafeRepository(apiClient))
    ..registerSingleton<MenuRepository>(MenuRepository(apiClient))
    ..registerSingleton<ReviewRepository>(ReviewRepository(apiClient))
    ..registerSingleton<FavoritesRepository>(FavoritesRepository(apiClient))
    ..registerSingleton<ReservationRepository>(ReservationRepository(apiClient));

  // ─── Session ────────────────────────────────────────────────────────
  sl.registerSingleton<AuthCubit>(AuthCubit(sl<AuthRepository>()));

  // ─── Router ─────────────────────────────────────────────────────────
  // One instance, owned here rather than built in a widget's initState: the
  // redirect reads the session, and tests need to drive navigation without
  // going through the tab bar, which on iOS is a native view with no Flutter
  // widgets to tap.
  sl.registerSingleton<GoRouter>(
    createRouter(authCubit: sl<AuthCubit>(), prefs: sl<AppPreferences>()),
  );

  // Registered last: the interceptor needs AuthCubit to exist so it can report
  // an expired session, and AuthCubit needs the repository above it.
  apiClient.addAuthInterceptor(
    AuthInterceptor(
      storage: sl<TokenStorage>(),
      refreshClient: refreshDio,
      onSessionExpired: () async {
        await sl<TokenStorage>().clear();
        sl<AuthCubit>().onSessionExpired();
      },
    ),
  );
}

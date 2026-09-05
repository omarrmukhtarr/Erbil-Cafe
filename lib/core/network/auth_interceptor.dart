import 'dart:async';

import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

/// Attaches the access token and transparently refreshes it on a 401.
///
/// The API rotates refresh tokens and revokes every session if a already-used
/// one is presented, so two parallel refreshes would log the user out. A single
/// in-flight refresh is therefore shared: the first 401 starts it, and every
/// other request waits on the same future.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required TokenStorage storage,
    required Dio refreshClient,
    required Future<void> Function() onSessionExpired,
  })  : _storage = storage,
        _refreshClient = refreshClient,
        _onSessionExpired = onSessionExpired;

  final TokenStorage _storage;

  /// A separate Dio without this interceptor, so refreshing cannot recurse.
  final Dio _refreshClient;

  final Future<void> Function() _onSessionExpired;

  Future<String?>? _refreshInFlight;

  /// Endpoints that must never carry a token or trigger a refresh.
  static const _publicPaths = {
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
    '/auth/otp/request',
    '/auth/otp/verify',
    '/auth/password/reset',
  };

  bool _isPublic(String path) => _publicPaths.any(path.endsWith);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isPublic(options.path)) {
      final token = await _storage.readAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final response = err.response;
    final path = err.requestOptions.path;

    final shouldRefresh = response?.statusCode == 401 &&
        !_isPublic(path) &&
        // Guard against a retried request 401ing again and looping.
        err.requestOptions.extra['retried'] != true;

    if (!shouldRefresh) {
      handler.next(err);
      return;
    }

    final token = await _refresh();

    if (token == null) {
      await _onSessionExpired();
      handler.next(err);
      return;
    }

    try {
      final options = err.requestOptions
        ..headers['Authorization'] = 'Bearer $token'
        ..extra['retried'] = true;

      final retried = await _refreshClient.fetch<dynamic>(options);
      handler.resolve(retried);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Returns a fresh access token, or null when the session is truly over.
  Future<String?> _refresh() {
    // Collapse concurrent refreshes into one network call.
    return _refreshInFlight ??= _performRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<String?> _performRefresh() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) return null;

    try {
      final response = await _refreshClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data;
      if (data == null) return null;

      final access = data['accessToken'] as String?;
      final refresh = data['refreshToken'] as String?;
      if (access == null || refresh == null) return null;

      // Rotation means the old refresh token is now dead — persist the new pair
      // before anything else can use it.
      await _storage.saveTokens(accessToken: access, refreshToken: refresh);
      return access;
    } on DioException {
      await _storage.clear();
      return null;
    }
  }
}

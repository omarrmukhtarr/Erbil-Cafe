import 'dart:async';

import 'package:dio/dio.dart';

import '../storage/token_storage.dart';

/// Attaches the access token and transparently refreshes it on a 401.
///
/// A 401 arrives here as a *response*, not an error: [ApiClient] lets every
/// status under 500 through so it can read error bodies. This interceptor
/// used to handle 401s only in `onError`, which therefore never saw one — no
/// token was ever refreshed, and fifteen minutes after signing in every
/// account request failed. `test/core/auth_refresh_test.dart` pins that.
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

  Future<_Refresh>? _refreshInFlight;

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

  bool _shouldRefresh(int? status, RequestOptions options) =>
      status == 401 &&
      !_isPublic(options.path) &&
      // Guard against a retried request 401ing again and looping.
      options.extra['retried'] != true;

  @override
  Future<void> onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) async {
    if (!_shouldRefresh(response.statusCode, response.requestOptions)) {
      handler.next(response);
      return;
    }

    final outcome = await _refresh();
    final options = response.requestOptions;

    switch (outcome) {
      case _Refreshed(:final accessToken):
        try {
          handler.resolve(await _retry(options, accessToken));
        } on DioException catch (e) {
          handler.reject(e);
        }
      case _Rejected():
        await _onSessionExpired();
        handler.next(response);
      case _Unreachable(:final error):
        handler.reject(error);
    }
  }

  /// Kept for a 401 raised as an error, should the client's status handling
  /// ever change back.
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (!_shouldRefresh(err.response?.statusCode, err.requestOptions)) {
      handler.next(err);
      return;
    }

    switch (await _refresh()) {
      case _Refreshed(:final accessToken):
        try {
          handler.resolve(await _retry(err.requestOptions, accessToken));
        } on DioException catch (e) {
          handler.next(e);
        }
      case _Rejected():
        await _onSessionExpired();
        handler.next(err);
      case _Unreachable(:final error):
        handler.next(error);
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions options, String token) {
    options
      ..headers['Authorization'] = 'Bearer $token'
      ..extra['retried'] = true;
    return _refreshClient.fetch<dynamic>(options);
  }

  Future<_Refresh> _refresh() {
    // Collapse concurrent refreshes into one network call.
    return _refreshInFlight ??= _performRefresh().whenComplete(() {
      _refreshInFlight = null;
    });
  }

  Future<_Refresh> _performRefresh() async {
    final refreshToken = await _storage.readRefreshToken();
    if (refreshToken == null) return const _Rejected();

    try {
      final response = await _refreshClient.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final data = response.data;
      final access = data?['accessToken'] as String?;
      final refresh = data?['refreshToken'] as String?;

      // A 4xx — revoked, expired, already rotated — is the server saying the
      // session is over.
      if (access == null || refresh == null) {
        await _storage.clear();
        return const _Rejected();
      }

      // Rotation means the old refresh token is now dead — persist the new pair
      // before anything else can use it.
      await _storage.saveTokens(accessToken: access, refreshToken: refresh);
      return _Refreshed(access);
    } on DioException catch (e) {
      // No connection, a timeout or a 5xx says nothing about the session.
      // This used to wipe the tokens, so a dropped connection at the wrong
      // moment signed the user out.
      return _Unreachable(e);
    }
  }
}

sealed class _Refresh {
  const _Refresh();
}

final class _Refreshed extends _Refresh {
  const _Refreshed(this.accessToken);
  final String accessToken;
}

final class _Rejected extends _Refresh {
  const _Rejected();
}

final class _Unreachable extends _Refresh {
  const _Unreachable(this.error);
  final DioException error;
}

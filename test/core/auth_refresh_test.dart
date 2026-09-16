import 'dart:convert';
import 'dart:io';

import 'package:erbilcafe/core/error/failure.dart';
import 'package:erbilcafe/core/network/api_client.dart';
import 'package:erbilcafe/core/network/auth_interceptor.dart';
import 'package:erbilcafe/core/storage/token_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

/// Token storage held in memory, standing in for the platform keystore.
class _MemoryStorage extends TokenStorage {
  _MemoryStorage() : super(const FlutterSecureStorage());

  String? access = 'expired';
  String? refresh = 'refresh-1';
  bool cleared = false;

  @override
  Future<String?> readAccessToken() async => access;

  @override
  Future<String?> readRefreshToken() async => refresh;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    access = accessToken;
    refresh = refreshToken;
  }

  @override
  Future<void> clear() async {
    cleared = true;
    access = null;
    refresh = null;
  }
}

/// The access token lives fifteen minutes; everything a signed-in person does
/// after that depends on the refresh path working.
///
/// The API client lets every status under 500 through as a *response* so the
/// error mapper can read the body — which means a 401 never became the
/// `DioException` the interceptor was waiting for, and no token was ever
/// refreshed.
void main() {
  late HttpServer server;
  late _MemoryStorage storage;
  var refreshCalls = 0;
  var refreshStatus = 200;
  var sessionExpired = false;

  setUp(() async {
    storage = _MemoryStorage();
    refreshCalls = 0;
    refreshStatus = 200;
    sessionExpired = false;

    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) async {
      final response = request.response
        ..headers.contentType = ContentType.json;

      if (request.uri.path.endsWith('/auth/refresh')) {
        refreshCalls++;
        response.statusCode = refreshStatus;
        response.write(jsonEncode(refreshStatus == 200
            ? {'accessToken': 'fresh', 'refreshToken': 'refresh-2'}
            : {'message': 'Invalid refresh token'}));
      } else if (request.headers.value('authorization') == 'Bearer fresh') {
        response.write(jsonEncode({'id': 'u1', 'name': 'Omer'}));
      } else {
        response.statusCode = 401;
        response.write(jsonEncode({'message': 'Unauthorized'}));
      }
      await response.close();
    });
  });

  tearDown(() => server.close(force: true));

  /// With [refreshPort], refreshes go to a port nothing listens on — the
  /// phone lost its connection between the request and the refresh.
  ApiClient client({int? refreshPort}) {
    final base = 'http://127.0.0.1:${server.port}/api/v1';
    final dio = ApiClient.createDio()..options.baseUrl = base;
    final refreshDio = ApiClient.createDio()
      ..options.baseUrl = 'http://127.0.0.1:${refreshPort ?? server.port}/api/v1';

    return ApiClient(dio)
      ..addAuthInterceptor(
        AuthInterceptor(
          storage: storage,
          refreshClient: refreshDio,
          onSessionExpired: () async {
            sessionExpired = true;
            await storage.clear();
          },
        ),
      );
  }

  test('an expired access token is refreshed and the request retried',
      () async {
    final me = await client().get<Map<String, dynamic>>('/users/me');

    expect(me['name'], 'Omer');
    expect(refreshCalls, 1);
    expect(storage.access, 'fresh');
    expect(storage.refresh, 'refresh-2');
    expect(sessionExpired, isFalse);
  });

  test('a rejected refresh ends the session', () async {
    refreshStatus = 401;

    await expectLater(
      client().get<Map<String, dynamic>>('/users/me'),
      throwsA(isA<UnauthorizedFailure>()),
    );
    expect(sessionExpired, isTrue);
    expect(storage.cleared, isTrue);
  });

  test('a refresh that cannot reach the server keeps the session', () async {
    // Bind and release a port, so nothing is listening on it.
    final closed = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    final deadPort = closed.port;
    await closed.close();

    // Signing out someone whose train went into a tunnel is not a session
    // ending; it must read as a network problem.
    await expectLater(
      client(refreshPort: deadPort).get<Map<String, dynamic>>('/users/me'),
      throwsA(isA<NetworkFailure>()),
    );
    expect(sessionExpired, isFalse);
    expect(storage.cleared, isFalse);
    expect(storage.refresh, 'refresh-1');
  });
}

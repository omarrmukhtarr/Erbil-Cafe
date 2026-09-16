import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import '../error/failure.dart';
import 'auth_interceptor.dart';
import 'response_cache.dart';

/// Thin wrapper over Dio that turns transport errors into [Failure]s, so
/// repositories never deal with [DioException] directly.
class ApiClient {
  ApiClient(this._dio);

  final Dio _dio;

  static Dio createDio({String? locale}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          if (locale != null) 'Accept-Language': locale,
        },
        // Let non-2xx responses through so the error mapper can read the body.
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseBody: false,
          compact: true,
        ),
      );
    }

    return dio;
  }

  void addAuthInterceptor(AuthInterceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Updates the language sent on every subsequent request.
  void setLocale(String languageCode) {
    // The API accepts `ckb` for Sorani; `ku` is the macrolanguage.
    final header = languageCode == 'ku' ? 'ckb' : languageCode;
    if (_dio.options.headers['Accept-Language'] == header) return;

    _dio.options.headers['Accept-Language'] = header;
    // Cached café text is in the old language.
    ResponseCache.shared.clear();
  }

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get<T>(path, queryParameters: query));

  Future<T> post<T>(String path, {Object? data, Map<String, dynamic>? query}) =>
      _send(() => _dio.post<T>(path, data: data, queryParameters: query));

  Future<T> patch<T>(String path, {Object? data}) =>
      _send(() => _dio.patch<T>(path, data: data));

  Future<T> delete<T>(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.delete<T>(path, queryParameters: query));

  Future<T> _send<T>(Future<Response<T>> Function() request) async {
    try {
      final response = await request();
      final status = response.statusCode ?? 500;

      if (status >= 400) {
        throw _failureFromResponse(response, status);
      }

      return response.data as T;
    } on DioException catch (e) {
      throw _failureFromDio(e);
    }
  }

  Failure _failureFromResponse(Response<dynamic> response, int status) {
    final body = response.data;
    final map = body is Map<String, dynamic> ? body : const <String, dynamic>{};

    final code = map['code'] as String?;
    final rawMessage = map['message'];

    // The validation pipe returns a list of messages; the rest return a string.
    final messages = rawMessage is List
        ? rawMessage.map((m) => m.toString()).toList()
        : <String>[];
    final message = messages.isNotEmpty
        ? messages.first
        : (rawMessage?.toString() ?? 'Something went wrong');

    return switch (status) {
      400 || 422 => ValidationFailure(message, code: code, fieldErrors: messages),
      401 => UnauthorizedFailure(message),
      403 => ForbiddenFailure(message, code: code),
      404 => NotFoundFailure(message),
      409 => ConflictFailure(message, code: code),
      429 => const RateLimitFailure(),
      _ => ServerFailure(message, code: code, statusCode: status),
    };
  }

  Failure _failureFromDio(DioException e) {
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout =>
        const TimeoutFailure(),
      DioExceptionType.connectionError => const NetworkFailure(),
      DioExceptionType.badCertificate =>
        const ServerFailure('Could not establish a secure connection'),
      DioExceptionType.cancel =>
        const ServerFailure('The request was cancelled'),
      _ => e.error is Failure
          ? e.error! as Failure
          : const ServerFailure('Something went wrong'),
    };
  }
}

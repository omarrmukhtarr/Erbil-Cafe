import 'package:equatable/equatable.dart';

/// A failure the UI can act on.
///
/// The API returns a stable machine-readable `code` alongside its message, so
/// screens branch on the type rather than string-matching prose that changes
/// with the request locale.
sealed class Failure extends Equatable {
  const Failure(this.message, {this.code});

  /// Safe to show the user as-is.
  final String message;

  /// The API's error code, e.g. `ALREADY_EXISTS`.
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// No usable connection — the request never left the device.
final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}

/// The request was sent but took too long.
final class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'The request timed out']);
}

/// 5xx, or a response the client could not parse.
final class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code, this.statusCode});

  final int? statusCode;

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// 400/422 — the input was rejected. [fieldErrors] carries every message when
/// the API returned a list, so a form can show them all at once.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code, this.fieldErrors = const []});

  final List<String> fieldErrors;

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// 401 — no valid session. Refreshing already failed by the time this surfaces.
final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Please sign in to continue']);
}

/// 403 — authenticated, but not allowed.
final class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message, {super.code});
}

/// 404.
final class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found']);
}

/// 409 — e.g. reviewing the same café twice.
final class ConflictFailure extends Failure {
  const ConflictFailure(super.message, {super.code});
}

/// 429 — throttled.
final class RateLimitFailure extends Failure {
  const RateLimitFailure([super.message = 'Too many attempts, please wait a moment']);
}

/// Nothing in the cache and no way to reach the network.
final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'No saved data available']);
}

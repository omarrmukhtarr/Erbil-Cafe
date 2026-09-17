import 'package:flutter/foundation.dart';

import '../../../core/error/failure.dart';
import 'notification_repository.dart';

/// The number on the bell.
///
/// One notifier the whole app shares, so the badge on Home, the inbox and a
/// push arriving in the foreground all agree without each fetching the count
/// on their own. It is refreshed when the app comes back to the foreground,
/// when someone signs in, and when a push lands.
class UnreadNotifications extends ValueNotifier<int> {
  UnreadNotifications._() : super(0);

  static final instance = UnreadNotifications._();

  NotificationRepository? _repository;

  /// Set once the repository exists. Until then — and in widget tests, which
  /// never set it — refreshing is a no-op and the badge stays at zero.
  void attach(NotificationRepository repository) => _repository = repository;

  Future<void> refresh() async {
    final repository = _repository;
    if (repository == null) return;

    try {
      value = await repository.unreadCount();
    } on Failure {
      // A badge that is briefly stale is better than one that errors.
    }
  }

  /// Signed out: nothing is anyone's to read.
  void clear() => value = 0;
}

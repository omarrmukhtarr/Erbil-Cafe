import 'package:equatable/equatable.dart';

/// One entry in the user's notification inbox.
///
/// The API resolves [title] and [body] into the request language, and [data]
/// carries what the notification is about — a `reservationId`, a `cafeId` or
/// `cafeSlug` — which is what tapping it opens.
class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.createdAt,
    this.data = const {},
    this.readAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: json['id'] as String,
        type: json['type'] as String? ?? 'SYSTEM',
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        data: (json['data'] as Map<String, dynamic>?) ?? const {},
        readAt: json['readAt'] == null
            ? null
            : DateTime.parse(json['readAt'] as String),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  final String id;

  /// `RESERVATION_CONFIRMED`, `REVIEW_REPLY`, `CAMPAIGN` …
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  bool get isRead => readAt != null;

  AppNotification markedRead() => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        data: data,
        readAt: readAt ?? DateTime.now(),
        createdAt: createdAt,
      );

  @override
  List<Object?> get props => [id, readAt];
}

/// A page of the inbox, with the unread total the API counts alongside it.
class NotificationPage {
  const NotificationPage({
    required this.items,
    required this.unreadCount,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<AppNotification> items;
  final int unreadCount;
  final String? nextCursor;
  final bool hasMore;
}

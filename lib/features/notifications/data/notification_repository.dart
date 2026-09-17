import '../../../core/network/api_client.dart';
import 'app_notification.dart';

class NotificationRepository {
  NotificationRepository(this._api);

  final ApiClient _api;

  Future<NotificationPage> inbox({String? cursor}) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/notifications',
      query: {'limit': 20, if (cursor != null) 'cursor': cursor},
    );

    return NotificationPage(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList(),
      unreadCount: json['unreadCount'] as int? ?? 0,
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool? ?? false,
    );
  }

  Future<int> unreadCount() async {
    final json =
        await _api.get<Map<String, dynamic>>('/notifications/unread-count');
    return json['count'] as int? ?? 0;
  }

  Future<void> markRead(String id) =>
      _api.patch<void>('/notifications/$id/read');

  Future<void> markAllRead() => _api.patch<void>('/notifications/read-all');
}

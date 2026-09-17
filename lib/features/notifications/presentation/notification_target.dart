import '../../../app/router/app_router.dart';

/// Where a notification leads, from its `data` payload.
///
/// Shared by the inbox and by a tapped push, so the two cannot disagree. A
/// booking leads to the bookings list rather than to one booking: that list is
/// where its status and the cancel button are. A café is opened by slug when
/// the payload has one and by id otherwise — the café route accepts both,
/// and older notifications were stored before slugs were added.
String? routeForNotification(Map<String, dynamic> data) {
  if (data['reservationId'] != null) return Routes.bookings;

  final slug = data['cafeSlug'] as String?;
  if (slug != null && slug.isNotEmpty) return Routes.cafe(slug);

  final cafeId = data['cafeId'] as String?;
  if (cafeId != null && cafeId.isNotEmpty) return Routes.cafe(cafeId);

  return null;
}

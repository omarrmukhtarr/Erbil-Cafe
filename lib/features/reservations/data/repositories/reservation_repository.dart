import '../../../../core/network/api_client.dart';
import '../../../cafes/data/models/cafe.dart';
import '../models/reservation.dart';

class ReservationRepository {
  ReservationRepository(this._api);

  final ApiClient _api;

  /// Bookable slots for a date, derived from the café's opening hours and the
  /// seats already committed across overlapping sittings.
  Future<Availability> availability(
    String cafeIdOrSlug, {
    required DateTime date,
    int partySize = 2,
  }) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/cafes/$cafeIdOrSlug/availability',
      query: {'date': _formatDate(date), 'partySize': partySize},
    );
    return Availability.fromJson(json);
  }

  Future<Reservation> create(
    String cafeId, {
    required DateTime date,
    required String time,
    required int partySize,
    required String contactName,
    required String contactPhone,
    String? note,
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/cafes/$cafeId/reservations',
      data: {
        'date': _formatDate(date),
        'time': time,
        'partySize': partySize,
        'contactName': contactName,
        'contactPhone': contactPhone,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
    return Reservation.fromJson(json);
  }

  Future<Paginated<Reservation>> mine({String? cursor}) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/reservations/mine',
      query: {'limit': 20, if (cursor != null) 'cursor': cursor},
    );
    return Paginated.fromJson(json, Reservation.fromJson);
  }

  Future<Reservation> cancel(String id) async {
    final json =
        await _api.patch<Map<String, dynamic>>('/reservations/$id/cancel');
    return Reservation.fromJson(json);
  }

  /// The API expects a plain calendar date with no timezone.
  static String _formatDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

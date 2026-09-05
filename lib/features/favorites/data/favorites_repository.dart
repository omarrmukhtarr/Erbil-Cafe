import '../../../core/network/api_client.dart';
import '../../cafes/data/models/cafe.dart';

class FavoritesRepository {
  FavoritesRepository(this._api);

  final ApiClient _api;

  Future<Paginated<Cafe>> list({String? cursor}) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/favorites',
      query: {'limit': 20, if (cursor != null) 'cursor': cursor},
    );
    return Paginated.fromJson(json, Cafe.fromJson);
  }

  /// Adds or removes in one call and returns the resulting state, so a
  /// duplicate tap cannot desynchronise the heart button.
  Future<bool> toggle(String cafeId) async {
    final json =
        await _api.post<Map<String, dynamic>>('/favorites/$cafeId/toggle');
    return json['isFavorited'] as bool? ?? false;
  }

  Future<int> count() async {
    final json = await _api.get<Map<String, dynamic>>('/favorites/count');
    return json['count'] as int? ?? 0;
  }
}

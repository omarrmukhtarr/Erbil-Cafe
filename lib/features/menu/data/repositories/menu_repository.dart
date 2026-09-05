import '../../../../core/network/api_client.dart';
import '../models/menu.dart';

class MenuRepository {
  MenuRepository(this._api);

  final ApiClient _api;

  Future<Menu> forCafe(String cafeIdOrSlug) async {
    final json = await _api.get<Map<String, dynamic>>('/cafes/$cafeIdOrSlug/menu');
    return Menu.fromJson(json);
  }

  /// Popular items across every café — the Home tab's feed.
  Future<List<PopularItem>> popular() async {
    final json = await _api.get<List<dynamic>>('/menu/popular');
    return json
        .map((e) => PopularItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

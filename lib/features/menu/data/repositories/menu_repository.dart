import '../../../../core/config/app_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/response_cache.dart';
import '../models/menu.dart';

class MenuRepository {
  MenuRepository(this._api);

  final ApiClient _api;

  /// Cached: going back and forth between a café and its menu should not
  /// download the menu each time.
  Future<Menu> forCafe(String cafeIdOrSlug) => ResponseCache.shared.get(
        '/cafes/$cafeIdOrSlug/menu',
        ttl: AppConfig.cacheTtl,
        fetch: () async {
          final json =
              await _api.get<Map<String, dynamic>>('/cafes/$cafeIdOrSlug/menu');
          return Menu.fromJson(json);
        },
      );

  /// Popular items across every café — the Home tab's feed.
  Future<List<PopularItem>> popular() => ResponseCache.shared.get(
        '/menu/popular',
        ttl: AppConfig.cacheTtl,
        fetch: () async {
          final json = await _api.get<List<dynamic>>('/menu/popular');
          return json
              .map((e) => PopularItem.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );
}

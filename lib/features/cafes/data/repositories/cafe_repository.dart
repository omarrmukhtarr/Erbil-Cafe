import '../../../../core/network/api_client.dart';
import '../models/cafe.dart';

/// Query for the café listing. Mirrors the API's filter surface.
class CafeQuery {
  const CafeQuery({
    this.search,
    this.area,
    this.priceRange,
    this.amenities = const [],
    this.minRating,
    this.openNow,
    this.featured,
    this.lat,
    this.lng,
    this.radiusKm,
    this.sort = 'rating',
    this.limit = 20,
    this.cursor,
  });

  final String? search;
  final String? area;
  final PriceRange? priceRange;
  final List<String> amenities;
  final double? minRating;
  final bool? openNow;
  final bool? featured;
  final double? lat;
  final double? lng;
  final double? radiusKm;
  final String sort;
  final int limit;
  final String? cursor;

  bool get hasFilters =>
      (search?.isNotEmpty ?? false) ||
      area != null ||
      priceRange != null ||
      amenities.isNotEmpty ||
      minRating != null ||
      openNow == true;

  CafeQuery copyWith({
    String? search,
    Object? area = _unset,
    Object? priceRange = _unset,
    List<String>? amenities,
    Object? minRating = _unset,
    Object? openNow = _unset,
    String? sort,
    String? cursor,
    double? lat,
    double? lng,
  }) =>
      CafeQuery(
        search: search ?? this.search,
        // Sentinel lets a caller clear a filter, which `?? this.x` cannot express.
        area: area == _unset ? this.area : area as String?,
        priceRange:
            priceRange == _unset ? this.priceRange : priceRange as PriceRange?,
        amenities: amenities ?? this.amenities,
        minRating: minRating == _unset ? this.minRating : minRating as double?,
        openNow: openNow == _unset ? this.openNow : openNow as bool?,
        featured: featured,
        lat: lat ?? this.lat,
        lng: lng ?? this.lng,
        radiusKm: radiusKm,
        sort: sort ?? this.sort,
        limit: limit,
        cursor: cursor,
      );

  Map<String, dynamic> toParams() => {
        if (search?.isNotEmpty ?? false) 'search': search,
        if (area != null) 'area': area,
        if (priceRange != null) 'priceRange': priceRange!.wire,
        if (amenities.isNotEmpty) 'amenities': amenities.join(','),
        if (minRating != null) 'minRating': minRating,
        if (openNow == true) 'openNow': true,
        if (featured == true) 'featured': true,
        if (lat != null && lng != null) ...{
          'lat': lat,
          'lng': lng,
          if (radiusKm != null) 'radiusKm': radiusKm,
        },
        'sort': sort,
        'limit': limit,
        if (cursor != null) 'cursor': cursor,
      };

  static const _unset = Object();
}

class CafeRepository {
  CafeRepository(this._api);

  final ApiClient _api;

  Future<Paginated<Cafe>> list(CafeQuery query) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/cafes',
      query: query.toParams(),
    );
    return Paginated.fromJson(json, Cafe.fromJson);
  }

  Future<CafeDetail> detail(String idOrSlug) async {
    final json = await _api.get<Map<String, dynamic>>('/cafes/$idOrSlug');
    return CafeDetail.fromJson(json);
  }

  /// Every active café as map pins. Small enough to fetch in one call.
  Future<List<CafeMarker>> markers() async {
    final json = await _api.get<List<dynamic>>('/cafes/map');
    return json
        .map((e) => CafeMarker.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<AreaCount>> areas() async {
    final json = await _api.get<List<dynamic>>('/cafes/areas');
    return json
        .map((e) => AreaCount.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class AreaCount {
  const AreaCount({required this.area, required this.count});

  factory AreaCount.fromJson(Map<String, dynamic> json) => AreaCount(
        area: json['area'] as String,
        count: json['count'] as int,
      );

  final String area;
  final int count;
}

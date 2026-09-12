import 'package:equatable/equatable.dart';

/// A café.
///
/// Replaces v1's `HotelListData`, which was copied from a hotel template and
/// still carried a `perNight` price field. Text arrives already resolved for the
/// request locale — the API does the ku → ar → en fallback server-side.
class Cafe extends Equatable {
  const Cafe({
    required this.id,
    required this.slug,
    required this.name,
    required this.description,
    required this.address,
    required this.lat,
    required this.lng,
    required this.priceRange,
    required this.ratingAvg,
    required this.reviewCount,
    required this.isFeatured,
    required this.isOpenNow,
    required this.amenities,
    this.area,
    this.coverImage,
    this.coverThumb,
    this.distanceKm,
    this.isFavorited = false,
  });

  factory Cafe.fromJson(Map<String, dynamic> json) => Cafe(
        id: json['id'] as String,
        slug: json['slug'] as String,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        address: json['address'] as String? ?? '',
        area: json['area'] as String?,
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        coverImage: json['coverImage'] as String?,
        coverThumb: json['coverThumb'] as String?,
        priceRange: PriceRange.fromJson(json['priceRange'] as String?),
        ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
        reviewCount: json['reviewCount'] as int? ?? 0,
        isFeatured: json['isFeatured'] as bool? ?? false,
        isOpenNow: json['isOpenNow'] as bool? ?? false,
        // Absent for anonymous callers; the API only includes it when signed in.
        isFavorited: json['isFavorited'] as bool? ?? false,
        distanceKm: (json['distanceKm'] as num?)?.toDouble(),
        amenities: (json['amenities'] as List<dynamic>? ?? [])
            .map((a) => Amenity.fromJson(a as Map<String, dynamic>))
            .toList(),
      );

  final String id;
  final String slug;
  final String name;
  final String description;
  final String address;
  final String? area;
  final double lat;
  final double lng;
  final String? coverImage;

  /// The 400px rendition of [coverImage], when the API holds one.
  ///
  /// A card is a few hundred points wide and has no use for the full size —
  /// which is up to 1600px, and 7 MB once decoded. Null means the API has no
  /// thumbnail for this cover, not that there is no cover.
  final String? coverThumb;
  final PriceRange priceRange;
  final double ratingAvg;
  final int reviewCount;
  final bool isFeatured;
  final bool isOpenNow;
  final bool isFavorited;

  /// Only present when the query supplied coordinates.
  final double? distanceKm;

  final List<Amenity> amenities;

  Cafe copyWith({bool? isFavorited}) => Cafe(
        id: id,
        slug: slug,
        name: name,
        description: description,
        address: address,
        area: area,
        lat: lat,
        lng: lng,
        coverImage: coverImage,
        coverThumb: coverThumb,
        priceRange: priceRange,
        ratingAvg: ratingAvg,
        reviewCount: reviewCount,
        isFeatured: isFeatured,
        isOpenNow: isOpenNow,
        isFavorited: isFavorited ?? this.isFavorited,
        distanceKm: distanceKm,
        amenities: amenities,
      );

  @override
  List<Object?> get props => [id, isFavorited, ratingAvg, reviewCount];
}

/// A café with the fields only returned by the detail endpoint.
class CafeDetail extends Equatable {
  const CafeDetail({
    required this.cafe,
    required this.images,
    required this.openingHours,
    required this.capacity,
    this.phone,
    this.whatsapp,
    this.instagram,
    this.website,
  });

  factory CafeDetail.fromJson(Map<String, dynamic> json) => CafeDetail(
        cafe: Cafe.fromJson(json),
        phone: json['phone'] as String?,
        whatsapp: json['whatsapp'] as String?,
        instagram: json['instagram'] as String?,
        website: json['website'] as String?,
        capacity: json['capacity'] as int? ?? 0,
        images: (json['images'] as List<dynamic>? ?? [])
            .map((i) => CafeImage.fromJson(i as Map<String, dynamic>))
            .toList(),
        openingHours: (json['openingHours'] as List<dynamic>? ?? [])
            .map((h) => OpeningHour.fromJson(h as Map<String, dynamic>))
            .toList(),
      );

  final Cafe cafe;
  final String? phone;
  final String? whatsapp;
  final String? instagram;
  final String? website;
  final int capacity;
  final List<CafeImage> images;
  final List<OpeningHour> openingHours;

  @override
  List<Object?> get props => [cafe, images, openingHours];
}

class CafeImage extends Equatable {
  const CafeImage({required this.id, required this.url, this.thumbUrl, this.caption});

  factory CafeImage.fromJson(Map<String, dynamic> json) => CafeImage(
        id: json['id'] as String,
        url: json['url'] as String,
        thumbUrl: json['thumbUrl'] as String?,
        caption: json['caption'] as String?,
      );

  final String id;
  final String url;
  final String? thumbUrl;
  final String? caption;

  @override
  List<Object?> get props => [id, url];
}

class OpeningHour extends Equatable {
  const OpeningHour({
    required this.dayOfWeek,
    required this.opensAt,
    required this.closesAt,
    required this.isClosed,
  });

  factory OpeningHour.fromJson(Map<String, dynamic> json) => OpeningHour(
        dayOfWeek: json['dayOfWeek'] as int,
        opensAt: json['opensAt'] as String,
        closesAt: json['closesAt'] as String,
        isClosed: json['isClosed'] as bool? ?? false,
      );

  /// 0 = Sunday.
  final int dayOfWeek;
  final String opensAt;
  final String closesAt;
  final bool isClosed;

  @override
  List<Object?> get props => [dayOfWeek, opensAt, closesAt, isClosed];
}

class Amenity extends Equatable {
  const Amenity({required this.key, required this.name, this.icon});

  factory Amenity.fromJson(Map<String, dynamic> json) => Amenity(
        key: json['key'] as String,
        name: json['name'] as String? ?? '',
        icon: json['icon'] as String?,
      );

  final String key;
  final String name;
  final String? icon;

  @override
  List<Object?> get props => [key];
}

enum PriceRange {
  budget('BUDGET', r'$'),
  moderate('MODERATE', r'$$'),
  upscale('UPSCALE', r'$$$');

  const PriceRange(this.wire, this.symbol);

  final String wire;
  final String symbol;

  static PriceRange fromJson(String? value) => PriceRange.values.firstWhere(
        (p) => p.wire == value,
        orElse: () => PriceRange.moderate,
      );
}

/// A map pin — the lighter shape returned by `/cafes/map`.
class CafeMarker extends Equatable {
  const CafeMarker({
    required this.id,
    required this.slug,
    required this.name,
    required this.lat,
    required this.lng,
    required this.ratingAvg,
    required this.reviewCount,
    required this.isOpenNow,
    this.area,
    this.coverImage,
  });

  factory CafeMarker.fromJson(Map<String, dynamic> json) => CafeMarker(
        id: json['id'] as String,
        slug: json['slug'] as String,
        name: json['name'] as String? ?? '',
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        area: json['area'] as String?,
        coverImage: json['coverImage'] as String?,
        ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0,
        reviewCount: json['reviewCount'] as int? ?? 0,
        isOpenNow: json['isOpenNow'] as bool? ?? false,
      );

  final String id;
  final String slug;
  final String name;
  final double lat;
  final double lng;
  final String? area;
  final String? coverImage;
  final double ratingAvg;
  final int reviewCount;
  final bool isOpenNow;

  @override
  List<Object?> get props => [id, lat, lng];
}

/// A cursor-paginated page.
class Paginated<T> {
  const Paginated({required this.items, this.nextCursor, this.hasMore = false, this.total});

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parse,
  ) =>
      Paginated(
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => parse(e as Map<String, dynamic>))
            .toList(),
        nextCursor: json['nextCursor'] as String?,
        hasMore: json['hasMore'] as bool? ?? false,
        total: json['total'] as int?,
      );

  final List<T> items;
  final String? nextCursor;
  final bool hasMore;
  final int? total;
}

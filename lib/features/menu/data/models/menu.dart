import 'package:equatable/equatable.dart';

/// A café's menu.
///
/// v1 hand-wrote this as three near-identical 419-line widget files, one per
/// café, differing only by class name. It is now data.
class Menu extends Equatable {
  const Menu({required this.cafeId, required this.categories, this.currency = 'IQD'});

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        cafeId: json['cafeId'] as String,
        currency: json['currency'] as String? ?? 'IQD',
        categories: (json['categories'] as List<dynamic>? ?? [])
            .map((c) => MenuCategory.fromJson(c as Map<String, dynamic>))
            .toList(),
      );

  final String cafeId;
  final String currency;
  final List<MenuCategory> categories;

  bool get isEmpty => categories.every((c) => c.items.isEmpty);

  @override
  List<Object?> get props => [cafeId, categories];
}

class MenuCategory extends Equatable {
  const MenuCategory({
    required this.id,
    required this.name,
    required this.items,
    this.icon,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        icon: json['icon'] as String?,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((i) => MenuItem.fromJson(i as Map<String, dynamic>))
            .toList(),
      );

  final String id;
  final String name;
  final String? icon;
  final List<MenuItem> items;

  @override
  List<Object?> get props => [id, name, items];
}

class MenuItem extends Equatable {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.priceIqd,
    required this.isAvailable,
    required this.isPopular,
    required this.tags,
    this.imageUrl,
    this.thumbUrl,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        description: json['description'] as String? ?? '',
        // Iraqi dinar has no practical subunit, so prices are whole numbers.
        priceIqd: json['priceIqd'] as int? ?? 0,
        imageUrl: json['imageUrl'] as String?,
        thumbUrl: json['thumbUrl'] as String?,
        isAvailable: json['isAvailable'] as bool? ?? true,
        isPopular: json['isPopular'] as bool? ?? false,
        tags: (json['tags'] as List<dynamic>? ?? []).cast<String>(),
      );

  final String id;
  final String name;
  final String description;
  final int priceIqd;
  final String? imageUrl;
  final String? thumbUrl;
  final bool isAvailable;
  final bool isPopular;
  final List<String> tags;

  @override
  List<Object?> get props => [id, priceIqd, isAvailable];
}

/// A popular item together with the café serving it — the Home tab's feed.
class PopularItem extends Equatable {
  const PopularItem({
    required this.item,
    required this.category,
    required this.cafeId,
    required this.cafeSlug,
    required this.cafeName,
    required this.cafeRating,
  });

  factory PopularItem.fromJson(Map<String, dynamic> json) {
    final cafe = json['cafe'] as Map<String, dynamic>? ?? const {};
    return PopularItem(
      item: MenuItem.fromJson(json),
      category: json['category'] as String? ?? '',
      cafeId: cafe['id'] as String? ?? '',
      cafeSlug: cafe['slug'] as String? ?? '',
      cafeName: cafe['name'] as String? ?? '',
      cafeRating: (cafe['ratingAvg'] as num?)?.toDouble() ?? 0,
    );
  }

  final MenuItem item;
  final String category;
  final String cafeId;
  final String cafeSlug;
  final String cafeName;
  final double cafeRating;

  @override
  List<Object?> get props => [item, cafeId];
}

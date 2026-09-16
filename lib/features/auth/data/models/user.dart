import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.locale,
    required this.emailVerified,
    required this.phoneVerified,
    this.email,
    this.phone,
    this.avatarUrl,
    this.stats,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        name: json['name'] as String? ?? '',
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
        role: json['role'] as String? ?? 'USER',
        locale: json['locale'] as String? ?? 'ku',
        emailVerified: json['emailVerified'] as bool? ?? false,
        phoneVerified: json['phoneVerified'] as bool? ?? false,
        stats: json['stats'] == null
            ? null
            : UserStats.fromJson(json['stats'] as Map<String, dynamic>),
      );

  final String id;
  final String name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final String role;
  final String locale;
  final bool emailVerified;
  final bool phoneVerified;

  /// Only returned by `/users/me`.
  final UserStats? stats;

  /// The same shape [AppUser.fromJson] reads, so a profile can be kept on the
  /// device and restored without a network round trip.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'role': role,
        'locale': locale,
        'emailVerified': emailVerified,
        'phoneVerified': phoneVerified,
        if (stats != null) 'stats': stats!.toJson(),
      };

  @override
  List<Object?> get props => [id, name, email, avatarUrl, locale];
}

class UserStats extends Equatable {
  const UserStats({
    required this.reviews,
    required this.favorites,
    required this.reservations,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) => UserStats(
        reviews: json['reviews'] as int? ?? 0,
        favorites: json['favorites'] as int? ?? 0,
        reservations: json['reservations'] as int? ?? 0,
      );

  final int reviews;
  final int favorites;
  final int reservations;

  Map<String, dynamic> toJson() => {
        'reviews': reviews,
        'favorites': favorites,
        'reservations': reservations,
      };

  @override
  List<Object?> get props => [reviews, favorites, reservations];
}

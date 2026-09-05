import 'package:equatable/equatable.dart';

class Review extends Equatable {
  const Review({
    required this.id,
    required this.rating,
    required this.images,
    required this.createdAt,
    required this.authorId,
    required this.authorName,
    this.comment,
    this.authorAvatar,
    this.reply,
    this.status,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final reply = json['reply'] as Map<String, dynamic>?;

    return Review(
      id: json['id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      images: (json['images'] as List<dynamic>? ?? []).cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      authorId: user['id'] as String? ?? '',
      authorName: user['name'] as String? ?? '',
      authorAvatar: user['avatarUrl'] as String?,
      reply: reply == null ? null : ReviewReply.fromJson(reply),
      status: json['status'] as String?,
    );
  }

  final String id;
  final int rating;
  final String? comment;
  final List<String> images;
  final DateTime createdAt;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final ReviewReply? reply;

  /// Only returned on the caller's own reviews. PENDING means it is not yet
  /// counted toward the café's average.
  final String? status;

  bool get isPending => status == 'PENDING';

  @override
  List<Object?> get props => [id, rating, comment, status];
}

class ReviewReply extends Equatable {
  const ReviewReply({required this.id, required this.body, required this.authorName});

  factory ReviewReply.fromJson(Map<String, dynamic> json) => ReviewReply(
        id: json['id'] as String,
        body: json['body'] as String,
        authorName: (json['author'] as Map<String, dynamic>?)?['name'] as String? ?? '',
      );

  final String id;
  final String body;
  final String authorName;

  @override
  List<Object?> get props => [id, body];
}

/// The star breakdown behind a café's average.
class RatingSummary extends Equatable {
  const RatingSummary({
    required this.total,
    required this.average,
    required this.distribution,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) => RatingSummary(
        total: json['total'] as int? ?? 0,
        average: (json['average'] as num?)?.toDouble() ?? 0,
        distribution: (json['distribution'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(int.parse(k), v as int)),
      );

  const RatingSummary.empty()
      : total = 0,
        average = 0,
        distribution = const {};

  final int total;
  final double average;

  /// Star value (1–5) to how many reviews gave it.
  final Map<int, int> distribution;

  /// Share of reviews at [stars], 0–1, for the breakdown bars.
  double fraction(int stars) =>
      total == 0 ? 0 : (distribution[stars] ?? 0) / total;

  @override
  List<Object?> get props => [total, average, distribution];
}

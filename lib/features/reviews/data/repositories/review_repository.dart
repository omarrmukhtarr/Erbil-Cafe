import '../../../../core/network/api_client.dart';
import '../../../cafes/data/models/cafe.dart';
import '../models/review.dart';

/// A page of reviews together with the café's rating breakdown.
class ReviewPage {
  const ReviewPage({required this.page, required this.summary});

  final Paginated<Review> page;
  final RatingSummary summary;
}

class ReviewRepository {
  ReviewRepository(this._api);

  final ApiClient _api;

  Future<ReviewPage> forCafe(String cafeIdOrSlug, {String? cursor}) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/cafes/$cafeIdOrSlug/reviews',
      query: {'limit': 20, if (cursor != null) 'cursor': cursor},
    );

    return ReviewPage(
      page: Paginated.fromJson(json, Review.fromJson),
      summary: json['summary'] == null
          ? const RatingSummary.empty()
          : RatingSummary.fromJson(json['summary'] as Map<String, dynamic>),
    );
  }

  /// Creates a review. It is held for moderation, so it will not appear in the
  /// café's list or affect its average until an administrator approves it.
  Future<Review> create(
    String cafeId, {
    required int rating,
    String? comment,
    List<String> images = const [],
  }) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/cafes/$cafeId/reviews',
      data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
        if (images.isNotEmpty) 'images': images,
      },
    );
    return Review.fromJson(json);
  }

  Future<Review> update(
    String reviewId, {
    required int rating,
    String? comment,
  }) async {
    final json = await _api.patch<Map<String, dynamic>>(
      '/reviews/$reviewId',
      data: {
        'rating': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
    return Review.fromJson(json);
  }

  Future<void> delete(String reviewId) => _api.delete<void>('/reviews/$reviewId');

  /// The caller's own reviews, including any still awaiting moderation.
  Future<Paginated<Review>> mine({String? cursor}) async {
    final json = await _api.get<Map<String, dynamic>>(
      '/reviews/mine',
      query: {'limit': 20, if (cursor != null) 'cursor': cursor},
    );
    return Paginated.fromJson(json, Review.fromJson);
  }
}

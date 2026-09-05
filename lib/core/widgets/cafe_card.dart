import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../features/cafes/data/models/cafe.dart';
import '../../l10n/app_localizations.dart';

/// The café card.
///
/// Keeps v1's anatomy: a full-bleed photo, the rating chip notched into the
/// top-right corner on the dark `badge` colour, and the details beneath. The
/// Hero tag matches the detail screen so the image expands into it, as before.
class CafeCard extends StatelessWidget {
  const CafeCard({
    required this.cafe,
    required this.onTap,
    this.onFavoriteTap,
    this.compact = false,
    super.key,
  });

  final Cafe cafe;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;

  /// Fixed-height layout for horizontal carousels.
  ///
  /// A carousel gives every tile the same height, so the content has to be a
  /// predictable height too. Kurdish and Arabic wrap taller than English, so
  /// the description is dropped and amenities are capped at a single row —
  /// otherwise the tallest translation overflows the tile.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: AppRadius.cardR,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: compact ? 150 : null,
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                  Hero(
                    tag: 'cafe-image-${cafe.id}',
                    child: _CafeImage(url: cafe.coverImage),
                  ),

                  // Scrim so the chips stay legible over a bright photo.
                  const DecoratedBox(
                    decoration: BoxDecoration(gradient: AppColors.imageScrim),
                  ),

                  if (cafe.isFeatured)
                    Positioned(
                      top: AppSpacing.md,
                      left: AppSpacing.md,
                      child: _Chip(
                        label: l10n.featured,
                        background: AppColors.cream,
                        foreground: AppColors.background,
                      ),
                    ),

                  if (cafe.reviewCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _RatingBadge(
                        rating: cafe.ratingAvg,
                        reviews: cafe.reviewCount,
                      ),
                    ),

                  if (onFavoriteTap != null)
                    Positioned(
                      bottom: AppSpacing.md,
                      right: AppSpacing.md,
                      child: _FavoriteButton(
                        isFavorited: cafe.isFavorited,
                        onTap: onFavoriteTap!,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cafe.name,
                          style: theme.textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        cafe.priceRange.symbol,
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: AppColors.accent),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          cafe.area ?? '',
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        cafe.isOpenNow ? l10n.openNow : l10n.closed,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cafe.isOpenNow
                              ? AppColors.success
                              : AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (cafe.distanceKm != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          l10n.distanceAway(cafe.distanceKm!.toStringAsFixed(1)),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                  if (!compact && cafe.description.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      cafe.description,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (cafe.amenities.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    if (compact)
                      // One row, clipped — never a second line that would grow
                      // the tile past the carousel's fixed height.
                      SizedBox(
                        height: 22,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cafe.amenities.length.clamp(0, 3),
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (context, index) => _Chip(
                            label: cafe.amenities[index].name,
                            background:
                                theme.colorScheme.surfaceContainerHighest,
                            foreground: AppColors.textMuted,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.xs,
                        children: [
                          for (final amenity in cafe.amenities.take(3))
                            _Chip(
                              label: amenity.name,
                              background:
                                  theme.colorScheme.surfaceContainerHighest,
                              foreground: AppColors.textMuted,
                            ),
                          if (cafe.amenities.length > 3)
                            _Chip(
                              label: '+${cafe.amenities.length - 3}',
                              background:
                                  theme.colorScheme.surfaceContainerHighest,
                              foreground: AppColors.textMuted,
                            ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CafeImage extends StatelessWidget {
  const _CafeImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(Icons.local_cafe_outlined,
              size: 40, color: AppColors.textDisabled),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      // A flat placeholder rather than a spinner — a grid of spinners is noisy.
      placeholder: (context, _) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
      ),
      errorWidget: (context, _, __) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(Icons.local_cafe_outlined,
              size: 40, color: AppColors.textDisabled),
        ),
      ),
    );
  }
}

/// The rating chip notched into the card's corner, as in v1's menu tiles.
class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating, required this.reviews});

  final double rating;
  final int reviews;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.badge,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(AppRadius.card),
          bottomLeft: Radius.circular(AppRadius.input),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: AppColors.cream,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorited, required this.onTap});

  final bool isFavorited;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.badge.withValues(alpha: 0.85),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: AppColors.accent,
            semanticLabel: isFavorited ? 'Saved' : 'Save',
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.pillR,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

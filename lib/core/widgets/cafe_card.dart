import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../features/cafes/data/models/cafe.dart';
import '../../l10n/app_localizations.dart';
import 'app_card.dart';

/// The café card: a near-black tile on the cream page, as v1 drew it.
///
/// Anatomy carried over from v1 — full-bleed photo, the rating chip notched
/// into the top-right corner on `#231715`, details beneath on the dark surface.
/// The Hero tag matches the detail screen so the image expands into it.
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
  /// A carousel gives every tile the same height, so the content must be a
  /// predictable height too. Kurdish and Arabic wrap taller than English, so
  /// the description is dropped and amenities are capped at one row — otherwise
  /// the tallest translation overflows the tile.
  final bool compact;

  static const imageHeightCompact = 148.0;

  /// Height of the compact tile, so carousels can size themselves from one
  /// number instead of a magic constant guessed per call site.
  static const compactHeight = 268.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: compact ? imageHeightCompact : null,
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
                      child: _Pill(
                        label: l10n.featured,
                        background: AppColors.cream,
                        foreground: AppColors.onCream,
                      ),
                    ),

                  if (cafe.reviewCount > 0)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: _RatingBadge(rating: cafe.ratingAvg),
                    ),

                  if (onFavoriteTap != null)
                    Positioned(
                      bottom: AppSpacing.md,
                      right: AppSpacing.md,
                      child: _FavoriteButton(
                        isFavorited: cafe.isFavorited,
                        onTap: onFavoriteTap!,
                        label: l10n.favorites,
                      ),
                    ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        cafe.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(color: AppColors.onCard),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const HGap.sm(),
                    Text(
                      cafe.priceRange.symbol,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: AppColors.accent),
                    ),
                  ],
                ),
                const Gap(6),

                _MetaRow(cafe: cafe, l10n: l10n),

                if (!compact && cafe.description.isNotEmpty) ...[
                  const Gap.sm(),
                  Text(
                    cafe.description,
                    style: const TextStyle(
                      color: AppColors.onCardMuted,
                      fontSize: 13,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                if (cafe.amenities.isNotEmpty) ...[
                  const Gap.md(),
                  if (compact)
                    // One clipped row — never a second line that would grow the
                    // tile past the carousel's fixed height.
                    SizedBox(
                      height: 24,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cafe.amenities.length.clamp(0, 3),
                        separatorBuilder: (_, __) => const HGap.sm(),
                        itemBuilder: (context, index) => _Pill(
                          label: cafe.amenities[index].name,
                          background: AppColors.cardDarkAlt,
                          foreground: AppColors.onCardMuted,
                        ),
                      ),
                    )
                  else
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final amenity in cafe.amenities.take(4))
                          _Pill(
                            label: amenity.name,
                            background: AppColors.cardDarkAlt,
                            foreground: AppColors.onCardMuted,
                          ),
                        if (cafe.amenities.length > 4)
                          _Pill(
                            label: '+${cafe.amenities.length - 4}',
                            background: AppColors.cardDarkAlt,
                            foreground: AppColors.onCardMuted,
                          ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.cafe, required this.l10n});

  final Cafe cafe;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    const muted = TextStyle(color: AppColors.onCardMuted, fontSize: 13);

    return Row(
      children: [
        const Icon(Icons.location_on_outlined,
            size: 14, color: AppColors.onCardMuted),
        const HGap(4),
        Flexible(
          child: Text(
            cafe.area ?? '',
            style: muted,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const HGap.sm(),
        Text(
          cafe.isOpenNow ? l10n.openNow : l10n.closed,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cafe.isOpenNow
                ? AppColors.successOnDark
                : AppColors.onCardMuted,
          ),
        ),
        if (cafe.distanceKm != null) ...[
          const HGap.sm(),
          Flexible(
            child: Text(
              l10n.distanceAway(cafe.distanceKm!.toStringAsFixed(1)),
              style: muted,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}

class _CafeImage extends StatelessWidget {
  const _CafeImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    // The placeholder sits inside the dark card, so it uses the dark ramp
    // rather than the page's cream.
    const placeholder = ColoredBox(
      color: AppColors.cardDarkAlt,
      child: Center(
        child: Icon(Icons.local_cafe_outlined,
            size: 36, color: AppColors.onCardDisabled),
      ),
    );

    if (url == null) return placeholder;

    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      // A flat fill rather than a spinner — a grid of spinners is noisy.
      placeholder: (context, _) => const ColoredBox(color: AppColors.cardDarkAlt),
      errorWidget: (context, _, __) => placeholder,
    );
  }
}

/// The rating chip notched into the card's corner, as in v1's tiles.
class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.rating});

  final double rating;

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
          const HGap(4),
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
  const _FavoriteButton({
    required this.isFavorited,
    required this.onTap,
    required this.label,
  });

  final bool isFavorited;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isFavorited,
      label: label,
      child: Material(
        color: AppColors.badge.withValues(alpha: 0.88),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          // 40pt keeps the target tappable without dominating the photo.
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              isFavorited ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: AppRadius.pillR),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

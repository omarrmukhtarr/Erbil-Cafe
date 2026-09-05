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
                    child: _CafeImage(
                      url: cafe.coverImage,
                      name: cafe.name,
                    ),
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
  const _CafeImage({required this.name, this.url});

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    if (url == null) return _NoPhoto(name: name, reason: _NoPhotoReason.missing);

    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 200),
      // A flat fill rather than a spinner — a grid of spinners is noisy.
      placeholder: (context, _) =>
          const ColoredBox(color: AppColors.cardDarkAlt),
      errorWidget: (context, _, __) =>
          _NoPhoto(name: name, reason: _NoPhotoReason.failed),
    );
  }
}

enum _NoPhotoReason { missing, failed }

/// Stands in for a café photo.
///
/// A bare grey box with a generic cup icon left people wondering whether the
/// image was still loading or the app was broken. This says which, and fills
/// the space with the café's own initials over a tint derived from its name —
/// so a list of photo-less cafés still looks deliberate and stays
/// distinguishable at a glance.
class _NoPhoto extends StatelessWidget {
  const _NoPhoto({required this.name, required this.reason});

  final String name;
  final _NoPhotoReason reason;

  /// Same name always yields the same shade, so a café looks consistent
  /// wherever it appears.
  Color get _tint {
    const ramp = [
      AppColors.brownDarkest,
      AppColors.brownMid,
      AppColors.brownWarm,
      AppColors.brownDeep,
      AppColors.badge,
    ];
    if (name.isEmpty) return ramp.first;
    final hash = name.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    return ramp[hash % ramp.length];
  }

  String get _initials {
    final words =
        name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.characters.first.toUpperCase();
    return (words[0].characters.first + words[1].characters.first).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final failed = reason == _NoPhotoReason.failed;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _tint.withValues(alpha: 0.85),
            AppColors.cardDarkAlt,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _initials,
              style: const TextStyle(
                color: AppColors.cream,
                fontFamily: 'Poppins',
                fontSize: 30,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const Gap.sm(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  failed ? Icons.wifi_off_rounded : Icons.image_not_supported_outlined,
                  size: 13,
                  color: AppColors.cream.withValues(alpha: 0.75),
                ),
                const HGap(5),
                Text(
                  failed ? l10n.photoUnavailable : l10n.noPhotoYet,
                  style: TextStyle(
                    color: AppColors.cream.withValues(alpha: 0.75),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

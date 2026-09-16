import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_motion.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../features/cafes/data/models/cafe.dart';
import '../../l10n/app_localizations.dart';
import 'app_card.dart';

/// The café card: a near-black tile on the cream page, as v1 drew it.
///
/// Anatomy carried over from v1 — full-bleed photo, the rating in the
/// top corner on `#231715`, details beneath on the dark surface.
/// The Hero tag matches the detail screen so the image expands into it.
///
/// Everything that is *status* rides on the photo (rating, open/closed,
/// featured, saved) and everything that is *identity* sits in the block
/// beneath it (name, area, price, what the place offers). Keeping those two
/// jobs on separate surfaces is what stops the compact tile reading as a wall
/// of small grey text.
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

  static const imageHeightCompact = 158.0;

  /// Height of the compact tile, so carousels can size themselves from one
  /// number instead of a magic constant guessed per call site.
  static const compactHeight = 278.0;

  /// The width a card's photo is decoded at.
  ///
  /// Shared with the café page, which shows the card's thumbnail as its
  /// placeholder: [ImageCache] keys on this number, so the page only gets the
  /// already-decoded bitmap — and a photo in the first frame of the Hero
  /// flight, instead of a dark box — if both ask for the same width.
  static int thumbCacheWidth(BuildContext context) =>
      (600 * MediaQuery.devicePixelRatioOf(context)).round();

  /// The image a card shows for [cafe].
  static String? thumbUrl(Cafe cafe) => cafe.coverThumb ?? cafe.coverImage;

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
          _Photo(cafe: cafe, compact: compact, onFavoriteTap: onFavoriteTap),
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
                  // One measured row on every card — never a clipped pill,
                  // and never a `+3` stranded on a line of its own, which is
                  // what the wrapping version left under a long amenity list.
                  AmenityStrip(amenities: cafe.amenities),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The photo and everything that rides on it.
class _Photo extends StatelessWidget {
  const _Photo({
    required this.cafe,
    required this.compact,
    required this.onFavoriteTap,
  });

  final Cafe cafe;
  final bool compact;
  final VoidCallback? onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final image = Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'cafe-image-${cafe.id}',
          child: _CafeImage(
            // The thumbnail where there is one: a card is a few hundred
            // points wide, and the full-size cover decodes to ~7 MB.
            url: CafeCard.thumbUrl(cafe),
            name: cafe.name,
          ),
        ),

        // Scrim so the chips stay legible over a bright photo.
        const DecoratedBox(
          decoration: BoxDecoration(gradient: AppColors.imageScrim),
        ),

        // Top row: what the place *is* on the left, what people think of it
        // on the right.
        Positioned(
          top: AppSpacing.md,
          left: AppSpacing.md,
          right: AppSpacing.md,
          child: Row(
            children: [
              // The left badge takes whatever the right one leaves and hugs
              // the start of it. It used to be a Flexible followed by a
              // Spacer: equal flex split the spare width in half, so the badge
              // on the right stopped in the middle of the row instead of the
              // corner whenever the left one was narrower than that half.
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: cafe.isFeatured
                      ? Pill(
                          label: l10n.featured,
                          background: AppColors.cream,
                          foreground: AppColors.onCream,
                          icon: Icons.star_rounded,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
              const HGap.sm(),
              _RatingBadge(
                rating: cafe.ratingAvg,
                reviewCount: cafe.reviewCount,
                newLabel: l10n.newCafe,
              ),
            ],
          ),
        ),

        // Bottom row: whether you can go right now, and the save button.
        Positioned(
          bottom: AppSpacing.md,
          left: AppSpacing.md,
          right: AppSpacing.md,
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: _OpenBadge(
                    isOpen: cafe.isOpenNow,
                    label: cafe.isOpenNow ? l10n.openNow : l10n.closed,
                  ),
                ),
              ),
              if (onFavoriteTap != null) ...[
                const HGap.sm(),
                _FavoriteButton(
                  isFavorited: cafe.isFavorited,
                  onTap: onFavoriteTap!,
                  label: l10n.favorites,
                ),
              ],
            ],
          ),
        ),
      ],
    );

    // A carousel tile is a fixed height and full-bleed width; a list card takes
    // the full width and derives its height from the aspect ratio.
    return compact
        ? SizedBox(
            height: CafeCard.imageHeightCompact,
            width: double.infinity,
            child: image,
          )
        : AspectRatio(aspectRatio: 16 / 10, child: image);
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
        if (cafe.distanceKm != null) ...[
          const HGap.sm(),
          const Text('·', style: muted),
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
    if (url == null) {
      return _NoPhoto(name: name, reason: _NoPhotoReason.missing);
    }

    // Decode at roughly the size it is drawn at, whatever the source turns
    // out to be. Without this a café whose cover has no thumbnail — an
    // outside URL, or a gallery that was reordered before the API started
    // matching covers to renditions — quietly costs twelve times the memory
    // of one that has.
    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      memCacheWidth: CafeCard.thumbCacheWidth(context),
      fadeInDuration: AppMotion.fast,
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
///
/// The initials sit behind the chips rather than competing with them: large,
/// but at low contrast, so the eye still lands on the name in the block below.
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
    // Only words that start with a letter or digit, in any script: "N & Lemon
    // Cafe" read as "N&" when the ampersand counted as a word.
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) =>
            w.isNotEmpty && RegExp(r'^[\p{L}\p{N}]', unicode: true).hasMatch(w))
        .toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.characters.first.toUpperCase();
    return (words[0].characters.first + words[1].characters.first)
        .toUpperCase();
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
              style: TextStyle(
                color: AppColors.cream.withValues(alpha: 0.62),
                fontFamily: 'Poppins',
                fontSize: 30,
                fontWeight: FontWeight.w700,
                height: 1,
                letterSpacing: 1,
              ),
            ),
            const Gap.sm(),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  failed
                      ? Icons.wifi_off_rounded
                      : Icons.image_not_supported_outlined,
                  size: 13,
                  color: AppColors.cream.withValues(alpha: 0.55),
                ),
                const HGap(5),
                Text(
                  failed ? l10n.photoUnavailable : l10n.noPhotoYet,
                  style: TextStyle(
                    color: AppColors.cream.withValues(alpha: 0.55),
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

/// The rating chip on the photo's top corner.
///
/// A café with no reviews used to show nothing here, which read as a gap in
/// the design rather than a fact about the café. It now says "New" — an
/// invitation to be the first to rate it.
class _RatingBadge extends StatelessWidget {
  const _RatingBadge({
    required this.rating,
    required this.reviewCount,
    required this.newLabel,
  });

  final double rating;
  final int reviewCount;
  final String newLabel;

  @override
  Widget build(BuildContext context) {
    if (reviewCount == 0) {
      return Pill(
        label: newLabel,
        background: AppColors.badge.withValues(alpha: 0.9),
        foreground: AppColors.cream,
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(8, 5, 10, 5),
      decoration: BoxDecoration(
        color: AppColors.badge.withValues(alpha: 0.9),
        borderRadius: AppRadius.pillR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.accent),
          const HGap(3),
          // The average and the count share a baseline. Centred, the smaller
          // count rode up like a superscript next to the average.
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppColors.cream,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              const HGap(3),
              Text(
                '($reviewCount)',
                style: TextStyle(
                  color: AppColors.cream.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Open/closed as a dot-and-label chip on the photo.
///
/// It used to sit inline with the area, where a green word next to a grey one
/// competed with the café's own name. On the photo it is glanceable and the
/// meta row is free for the address.
class _OpenBadge extends StatelessWidget {
  const _OpenBadge({required this.isOpen, required this.label});

  final bool isOpen;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppColors.successOnDark : AppColors.onCardMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.badge.withValues(alpha: 0.9),
        borderRadius: AppRadius.pillR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const HGap(6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
          // 36pt keeps the target tappable without dominating the photo.
          child: SizedBox(
            width: 36,
            height: 36,
            child: PopSwitcher(
              child: Icon(
                isFavorited ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(isFavorited),
                size: 18,
                color: AppColors.accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One row of amenity pills, and a `+N` for whatever did not fit.
///
/// The previous version put three pills in a non-scrolling `ListView`, which
/// simply clipped the last one mid-word — "City vie…" with no indication that
/// more existed. This measures each label first and only lays out the pills
/// that fully fit, so the row always ends on a whole chip.
class AmenityStrip extends StatelessWidget {
  const AmenityStrip({required this.amenities, super.key});

  final List<Amenity> amenities;

  static const _height = 24.0;
  static const _gap = AppSpacing.sm;
  static const _style = TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600);

  /// Pill padding: 10 either side.
  ///
  /// [style] must be the style the pill will actually render with — the font
  /// family is inherited, and measuring with a different one is how this row
  /// used to be a few pixels out.
  static double _pillWidth(
    String label,
    TextStyle style,
    TextDirection direction,
    TextScaler scaler,
  ) {
    final painter = TextPainter(
      text: TextSpan(text: label, style: style),
      textDirection: direction,
      textScaler: scaler,
      maxLines: 1,
    )..layout();
    return painter.width + 20;
  }

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    final style = DefaultTextStyle.of(context).style.merge(_style);

    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.maxWidth;
          final shown = <Amenity>[];
          var used = 0.0;

          for (final amenity in amenities) {
            final width = _pillWidth(amenity.name, style, direction, scaler) +
                (shown.isEmpty ? 0 : _gap);
            final remaining = amenities.length - shown.length - 1;

            // Leave room for the `+N` chip when anything will be left over.
            final overflowWidth = remaining > 0
                ? _gap + _pillWidth('+$remaining', style, direction, scaler)
                : 0.0;

            // A pixel of slack: text measured here and text laid out by the
            // Row can round differently, and a hairline over is still an
            // overflow stripe.
            if (used + width + overflowWidth > available - 1) break;
            used += width;
            shown.add(amenity);
          }

          final hidden = amenities.length - shown.length;

          // Nothing fit — show the count alone rather than an empty row.
          if (shown.isEmpty) {
            return Align(
              alignment: AlignmentDirectional.centerStart,
              child: Pill(
                label: '+$hidden',
                background: AppColors.cardDarkAlt,
                foreground: AppColors.onCardMuted,
              ),
            );
          }

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < shown.length; i++) ...[
                if (i > 0) const HGap(_gap),
                Pill(
                  label: shown[i].name,
                  background: AppColors.cardDarkAlt,
                  foreground: AppColors.onCardMuted,
                ),
              ],
              if (hidden > 0) ...[
                const HGap(_gap),
                Pill(
                  label: '+$hidden',
                  background: AppColors.cardDarkAlt,
                  foreground: AppColors.onCardMuted,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// A small rounded label. Shared with the home carousels.
class Pill extends StatelessWidget {
  const Pill({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    super.key,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(icon == null ? 10 : 7, 5, 10, 5),
      decoration:
          BoxDecoration(color: background, borderRadius: AppRadius.pillR),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: foreground),
            const HGap(3),
          ],
          // Flexible so a pill in a width-constrained row ellipsizes instead
          // of pushing the row into an overflow stripe.
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: foreground,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

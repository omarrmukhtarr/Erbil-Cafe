import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/photo_viewer.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../favorites/data/favorites_repository.dart';
import '../../../menu/data/repositories/menu_repository.dart';
import '../../../reviews/data/models/review.dart';
import '../../../reviews/data/repositories/review_repository.dart';
import '../../data/models/cafe.dart';
import '../../data/repositories/cafe_repository.dart';
import '../cubit/cafe_detail_cubit.dart';

/// A café's page.
///
/// v1 had three of these — Barbera, Alreef and Nazdar — as separate files with
/// their content hardcoded. One screen now serves every café.
class CafeDetailScreen extends StatefulWidget {
  const CafeDetailScreen({required this.slug, super.key});

  final String slug;

  @override
  State<CafeDetailScreen> createState() => _CafeDetailScreenState();
}

class _CafeDetailScreenState extends State<CafeDetailScreen> {
  late final CafeDetailCubit _cubit;

  /// Height of the pinned booking bar, so content can clear it.
  static const _ctaHeight = 96.0;

  @override
  void initState() {
    super.initState();
    _cubit = CafeDetailCubit(
      cafes: sl<CafeRepository>(),
      menus: sl<MenuRepository>(),
      reviews: sl<ReviewRepository>(),
    )..load(widget.slug);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  /// The signed-in user's own review of this café, if they have left one.
  Review? _myReview(CafeDetailState state) {
    final userId = context.read<AuthCubit>().state.user?.id;
    if (userId == null) return null;

    for (final review in state.reviews) {
      if (review.authorId == userId) return review;
    }
    return null;
  }

  /// Rating from the café's own page, without a detour through a form.
  ///
  /// Writing a review is a paragraph of work; leaving a rating is one tap, and
  /// most people will only ever do the second. A comment is still one tap
  /// further, offered in the confirmation rather than demanded up front.
  Future<void> _rate(int stars, String cafeId, Review? mine) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final review = mine == null
          ? await sl<ReviewRepository>().create(cafeId, rating: stars)
          // Rating again replaces the previous rating rather than failing:
          // the API allows one review per person per café.
          : await sl<ReviewRepository>()
              .update(mine.id, rating: stars, comment: mine.comment);

      if (!mounted) return;
      await _cubit.reloadReviews();
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            review.isPending ? l10n.reviewPending : l10n.reviewPublished,
          ),
          action: SnackBarAction(
            label: l10n.writeReview,
            onPressed: () async {
              final wrote = await context.push<bool>(Routes.review(widget.slug));
              if ((wrote ?? false) && mounted) _cubit.reloadReviews();
            },
          ),
        ),
      );
    } on Failure catch (f) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(f.message)));
    }
  }

  /// Every photo of this café, cover included, in the order the dashboard
  /// put them in.
  ///
  /// A café with no gallery still has a cover, and that cover is worth opening
  /// full screen — so the cover stands in for the gallery when there is none
  /// rather than leaving the tap dead.
  static List<PhotoSource> _photosOf(CafeDetail detail) {
    final photos = [
      for (final image in detail.images)
        PhotoSource(url: image.url, thumbUrl: image.thumbUrl, caption: image.caption),
    ];

    if (photos.isEmpty && detail.cafe.coverImage != null) {
      photos.add(PhotoSource(url: detail.cafe.coverImage!));
    }
    return photos;
  }

  /// Whether there is anything to put in the contact card.
  ///
  /// Most OpenStreetMap cafés carry a coordinate and nothing else, and an
  /// empty "Contact & links" heading is worse than no heading.
  static bool _hasContactDetails(CafeDetail detail) =>
      (detail.cafe.address.isNotEmpty) ||
      (detail.website?.isNotEmpty ?? false) ||
      (detail.instagram?.isNotEmpty ?? false) ||
      (detail.whatsapp?.isNotEmpty ?? false) ||
      detail.capacity > 0;

  void _openPhotos(CafeDetail detail, int index) {
    final photos = _photosOf(detail);
    if (photos.isEmpty) return;

    PhotoViewer.open(
      context,
      photos: photos,
      initialIndex: index,
      heroPrefix: 'cafe-photo-${detail.cafe.id}',
    );
  }

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocBuilder<CafeDetailCubit, CafeDetailState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.status == DetailStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (state.status == DetailStatus.failure) {
            return SafeArea(
              child: Column(
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  Expanded(
                    child: ErrorView(
                      failure: state.failure!,
                      onRetry: () => _cubit.load(widget.slug),
                    ),
                  ),
                ],
              ),
            );
          }

          final detail = state.detail!;
          final cafe = detail.cafe;

          return CustomScrollView(
            slivers: [
              // Full-bleed header with the content riding over it, as v1 did.
              //
              // 380 rather than 300: the café's own photo is the single most
              // persuasive thing on this page and at 300 it was a strip behind
              // the status bar. This gives it roughly the top 45% of a phone.
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                stretch: true,
                backgroundColor: theme.colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                leading: _CircleButton(
                  icon: Icons.arrow_back,
                  onTap: () => context.pop(),
                  semanticLabel: l10n.close,
                ),
                actions: [
                  _CircleButton(
                    icon: cafe.isFavorited
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: cafe.isFavorited ? AppColors.accent : Colors.white,
                    semanticLabel: l10n.favorites,
                    onTap: () => requireAuth(
                      context,
                      reason: l10n.signInToFavorite,
                      action: () async {
                        final result =
                            await sl<FavoritesRepository>().toggle(cafe.id);
                        _cubit.applyFavorite(isFavorited: result);
                      },
                    ),
                  ),
                  const HGap.sm(),
                ],
                // The name moves into the bar as the photo scrolls away, so a
                // collapsed header is never an anonymous cream strip.
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final collapsed = constraints.maxHeight <=
                        kToolbarHeight + MediaQuery.paddingOf(context).top + 8;

                    return FlexibleSpaceBar(
                      titlePadding: const EdgeInsetsDirectional.only(
                        start: 60,
                        end: 60,
                        bottom: 16,
                      ),
                      title: AnimatedOpacity(
                        opacity: collapsed ? 1 : 0,
                        duration: AppMotion.fast,
                        child: Text(
                          cafe.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      background: _HeaderImage(
                        url: cafe.coverImage ??
                            (detail.images.isEmpty
                                ? null
                                : detail.images.first.url),
                        id: cafe.id,
                        photoCount: _photosOf(detail).length,
                        onTap: () => _openPhotos(detail, 0),
                        viewAllLabel: l10n.viewAllPhotos,
                      ),
                    );
                  },
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.xl,
                  AppSpacing.page,
                  // Clears the pinned booking bar.
                  _ctaHeight + AppSpacing.xl,
                ),
                sliver: SliverList.list(
                  children: [
                    _TitleBlock(cafe: cafe, l10n: l10n),

                    if (cafe.description.isNotEmpty) ...[
                      const Gap.lg(),
                      Text(cafe.description, style: theme.textTheme.bodyLarge),
                    ],

                    const Gap.xxl(),
                    _QuickActions(
                      phone: detail.phone,
                      onCall: () => _open('tel:${detail.phone}'),
                      onDirections: () => _open(
                        'https://www.google.com/maps/dir/?api=1'
                        '&destination=${cafe.lat},${cafe.lng}',
                      ),
                      onMenu: () => context.push(Routes.menu(widget.slug)),
                      l10n: l10n,
                    ),

                    if (cafe.amenities.isNotEmpty) ...[
                      const Gap.section(),
                      _Heading(l10n.amenities),
                      const Gap.md(),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final amenity in cafe.amenities)
                            _AmenityChip(label: amenity.name),
                        ],
                      ),
                    ],

                    if (detail.images.isNotEmpty) ...[
                      const Gap.section(),
                      Row(
                        children: [
                          Expanded(child: _Heading(l10n.gallery)),
                          Text(
                            l10n.photoCount(detail.images.length),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const Gap.md(),
                      // 260×180 rather than 150×128. A café photo at 150pt
                      // wide shows a wall and a corner of a table; at 260 it
                      // shows the room, which is what the tap is deciding on.
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          physics: const BouncingScrollPhysics(),
                          itemCount: detail.images.length,
                          separatorBuilder: (_, __) => const HGap.md(),
                          itemBuilder: (context, index) => _GalleryTile(
                            image: detail.images[index],
                            heroTag: 'cafe-photo-${cafe.id}-$index',
                            onTap: () => _openPhotos(detail, index),
                          ),
                        ),
                      ),
                    ],

                    if (_hasContactDetails(detail)) ...[
                      const Gap.section(),
                      _Heading(l10n.contactAndLinks),
                      const Gap.md(),
                      _ContactCard(
                        detail: detail,
                        l10n: l10n,
                        onOpen: _open,
                      ),
                    ],

                    if (detail.openingHours.isNotEmpty) ...[
                      const Gap.section(),
                      _Heading(l10n.openingHours),
                      const Gap.md(),
                      _OpeningHours(hours: detail.openingHours),
                    ],

                    // ─── Reviews ─────────────────────────────────
                    const Gap.section(),
                    Row(
                      children: [
                        Expanded(child: _Heading(l10n.reviews)),
                        TextButton(
                          onPressed: () => requireAuth(
                            context,
                            reason: l10n.signInToReview,
                            action: () async {
                              final wrote = await context
                                  .push<bool>(Routes.review(widget.slug));
                              if (wrote ?? false) _cubit.reloadReviews();
                            },
                          ),
                          child: Text(l10n.writeReview),
                        ),
                      ],
                    ),

                    const Gap.sm(),
                    _QuickRate(
                      myRating: _myReview(state)?.rating ?? 0,
                      onRate: (stars) => requireAuth(
                        context,
                        reason: l10n.signInToReview,
                        action: () => _rate(
                          stars,
                          detail.cafe.id,
                          _myReview(state),
                        ),
                      ),
                    ),

                    if (state.summary.total > 0) ...[
                      const Gap.md(),
                      _RatingBreakdown(summary: state.summary),
                    ],

                    const Gap.lg(),

                    if (state.reviews.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xxl),
                        child: Center(
                          child: Text(l10n.noReviewsYet,
                              style: theme.textTheme.bodySmall),
                        ),
                      )
                    else
                      for (final review in state.reviews.take(5))
                        _ReviewTile(review: review),
                  ],
                ),
              ),
            ],
          );
        },
      ),

      // The booking CTA v1 rendered as "Service Not Availabe For Now".
      bottomNavigationBar: BlocBuilder<CafeDetailCubit, CafeDetailState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.detail == null) return const SizedBox.shrink();

          return Container(
            // A solid strip so the CTA never sits on top of scrolling text.
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.md,
                  AppSpacing.page,
                  AppSpacing.md,
                ),
                child: ElevatedButton.icon(
                  onPressed: () => requireAuth(
                    context,
                    reason: l10n.signInToBook,
                    action: () async => context.push(Routes.book(widget.slug)),
                  ),
                  icon: const Icon(Icons.event_seat_outlined, size: 20),
                  label: Text(l10n.bookTable),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeaderImage extends StatelessWidget {
  const _HeaderImage({
    required this.url,
    required this.id,
    required this.photoCount,
    required this.onTap,
    required this.viewAllLabel,
  });

  final String? url;
  final String id;
  final int photoCount;
  final VoidCallback onTap;
  final String viewAllLabel;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: photoCount == 0 ? null : onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: 'cafe-image-$id',
            child: url == null
                ? const ColoredBox(
                    color: AppColors.cardDarkAlt,
                    child: Icon(Icons.local_cafe_outlined,
                        size: 48, color: AppColors.onCardDisabled),
                  )
                : CachedNetworkImage(
                    imageUrl: url!,
                    fit: BoxFit.cover,
                    fadeInDuration: AppMotion.fast,
                    placeholder: (context, _) =>
                        const ColoredBox(color: AppColors.cardDarkAlt),
                    errorWidget: (context, _, __) =>
                        const ColoredBox(color: AppColors.cardDarkAlt),
                  ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(gradient: AppColors.imageScrim),
          ),

          // Says the photo is worth touching. Without it the header reads as
          // decoration and nobody finds the gallery behind it.
          if (photoCount > 0)
            PositionedDirectional(
              end: AppSpacing.page,
              bottom: AppSpacing.lg,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: AppRadius.pillR,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_library_outlined,
                        size: 15, color: Colors.white),
                    const HGap(6),
                    Text(
                      photoCount > 1 ? '$photoCount' : viewAllLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// One photo in the horizontal gallery strip.
class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.image,
    required this.heroTag,
    required this.onTap,
  });

  final CafeImage image;
  final String heroTag;
  final VoidCallback onTap;

  static const _width = 260.0;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: AppRadius.cardR,
        child: SizedBox(
          width: _width,
          child: Hero(
            tag: heroTag,
            // The thumbnail is cropped and the full-screen photo is not, so
            // the flight has to interpolate between two different shapes.
            // Without this the image snaps to its uncropped aspect ratio on
            // the first frame of the flight.
            flightShuttleBuilder: (_, animation, __, ___, ____) => CachedNetworkImage(
              imageUrl: image.thumbUrl ?? image.url,
              fit: BoxFit.cover,
            ),
            child: CachedNetworkImage(
              imageUrl: image.thumbUrl ?? image.url,
              fit: BoxFit.cover,
              memCacheWidth:
                  (_width * MediaQuery.devicePixelRatioOf(context)).round(),
              fadeInDuration: AppMotion.fast,
              placeholder: (context, _) =>
                  const ColoredBox(color: AppColors.creamSunken),
              errorWidget: (context, _, __) => const ColoredBox(
                color: AppColors.creamSunken,
                child: Icon(Icons.image_not_supported_outlined,
                    color: AppColors.onCreamMuted),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Address, links and capacity — everything the dashboard sets on a café that
/// is not already a heading of its own.
///
/// These fields have been editable on the API since the beginning and the app
/// simply never showed them, so a café owner filling in their website saw it
/// go nowhere.
class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.detail,
    required this.l10n,
    required this.onOpen,
  });

  final CafeDetail detail;
  final AppLocalizations l10n;
  final void Function(String url) onOpen;

  @override
  Widget build(BuildContext context) {
    final cafe = detail.cafe;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        children: [
          if (cafe.address.isNotEmpty)
            _ContactRow(
              icon: Icons.place_outlined,
              label: l10n.address,
              value: cafe.address,
              onTap: () => onOpen(
                'https://www.google.com/maps/search/?api=1'
                '&query=${cafe.lat},${cafe.lng}',
              ),
            ),
          if (detail.website?.isNotEmpty ?? false)
            _ContactRow(
              icon: Icons.language_outlined,
              label: l10n.website,
              value: _prettyUrl(detail.website!),
              onTap: () => onOpen(detail.website!),
            ),
          if (detail.instagram?.isNotEmpty ?? false)
            _ContactRow(
              icon: Icons.camera_alt_outlined,
              label: l10n.instagram,
              value: '@${detail.instagram}',
              onTap: () =>
                  onOpen('https://instagram.com/${detail.instagram}'),
            ),
          if (detail.whatsapp?.isNotEmpty ?? false)
            _ContactRow(
              icon: Icons.chat_bubble_outline,
              label: l10n.whatsapp,
              value: detail.whatsapp!,
              // wa.me wants the number with no punctuation at all.
              onTap: () => onOpen(
                'https://wa.me/${detail.whatsapp!.replaceAll(RegExp(r'[^0-9]'), '')}',
              ),
            ),
          if (detail.capacity > 0)
            _ContactRow(
              icon: Icons.event_seat_outlined,
              label: l10n.bookTable,
              value: l10n.seats(detail.capacity),
            ),
        ],
      ),
    );
  }

  /// `https://www.barbera.krd/` reads as `barbera.krd`.
  static String _prettyUrl(String url) => url
      .replaceFirst(RegExp(r'^https?://'), '')
      .replaceFirst(RegExp(r'^www\.'), '')
      .replaceFirst(RegExp(r'/$'), '');
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.accent),
          const HGap.md(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.onCardMuted,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(3),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.onCard,
                    fontSize: 14,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.north_east,
                size: 15, color: AppColors.onCardMuted),
        ],
      ),
    );

    return onTap == null
        ? row
        : InkWell(
            onTap: onTap,
            borderRadius: AppRadius.chipR,
            child: row,
          );
  }
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock({required this.cafe, required this.l10n});

  final Cafe cafe;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(cafe.name, style: theme.textTheme.displayLarge),
            ),
            const HGap.md(),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                cafe.priceRange.symbol,
                style: theme.textTheme.titleLarge
                    ?.copyWith(color: AppColors.accent),
              ),
            ),
          ],
        ),
        const Gap.sm(),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.xs,
          children: [
            if (cafe.reviewCount > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded,
                      size: 18, color: AppColors.accent),
                  const HGap(4),
                  Text(cafe.ratingAvg.toStringAsFixed(1),
                      style: theme.textTheme.labelLarge),
                  const HGap(6),
                  Text(l10n.reviewCount(cafe.reviewCount),
                      style: theme.textTheme.bodySmall),
                ],
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: cafe.isOpenNow
                      ? AppColors.success
                      : AppColors.onCreamMuted,
                ),
                const HGap(6),
                Text(
                  cafe.isOpenNow ? l10n.openNow : l10n.closed,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cafe.isOpenNow
                        ? AppColors.success
                        : AppColors.onCreamMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            if (cafe.area != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 15, color: AppColors.onCreamMuted),
                  const HGap(4),
                  Text(cafe.area!, style: theme.textTheme.bodySmall),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

/// Call / Directions / Menu.
///
/// Drawn as dark tiles rather than tinted cream: a cream-on-cream button was
/// nearly invisible, and the dark surface matches the card language.
class _QuickActions extends StatelessWidget {
  const _QuickActions({
    required this.phone,
    required this.onCall,
    required this.onDirections,
    required this.onMenu,
    required this.l10n,
  });

  final String? phone;
  final VoidCallback onCall;
  final VoidCallback onDirections;
  final VoidCallback onMenu;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (phone != null) ...[
          Expanded(
            child: _ActionTile(
              icon: Icons.phone_outlined,
              label: l10n.call,
              onTap: onCall,
            ),
          ),
          const HGap.md(),
        ],
        Expanded(
          child: _ActionTile(
            icon: Icons.directions_outlined,
            label: l10n.directions,
            onTap: onDirections,
          ),
        ),
        const HGap.md(),
        Expanded(
          child: _ActionTile(
            icon: Icons.menu_book_outlined,
            label: l10n.menu,
            onTap: onMenu,
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 22, color: AppColors.accent),
          const Gap(6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.onCard,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: Theme.of(context).textTheme.titleLarge);
}

class _AmenityChip extends StatelessWidget {
  const _AmenityChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.creamSunken,
        borderRadius: AppRadius.pillR,
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.onCream,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _OpeningHours extends StatelessWidget {
  const _OpeningHours({required this.hours});

  final List<OpeningHour> hours;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final names = [
      l10n.sunday,
      l10n.monday,
      l10n.tuesday,
      l10n.wednesday,
      l10n.thursday,
      l10n.friday,
      l10n.saturday,
    ];

    // DateTime.weekday is 1=Monday…7=Sunday; the API uses 0=Sunday.
    final today = DateTime.now().weekday % 7;

    return Column(
      children: [
        for (final hour in hours)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    names[hour.dayOfWeek],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      // Highlight today so the current hours are findable.
                      color: hour.dayOfWeek == today
                          ? AppColors.accent
                          : AppColors.onCreamMuted,
                      fontWeight: hour.dayOfWeek == today
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  hour.isClosed
                      ? l10n.closed
                      : '${hour.opensAt} – ${hour.closesAt}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hour.dayOfWeek == today
                        ? AppColors.accent
                        : AppColors.onCreamMuted,
                    fontWeight: hour.dayOfWeek == today
                        ? FontWeight.w700
                        : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Five taps, one of which rates the café.
///
/// Sits above the breakdown so the invitation to rate comes before the wall of
/// other people's opinions. Once the user has rated, it shows their own stars
/// back and tapping a different one changes it.
class _QuickRate extends StatelessWidget {
  const _QuickRate({required this.myRating, required this.onRate});

  final int myRating;
  final void Function(int stars) onRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final rated = myRating > 0;

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rated ? l10n.yourRating : l10n.rateThisCafe,
                  style: theme.textTheme.labelLarge
                      ?.copyWith(color: AppColors.onCard),
                ),
                const Gap(2),
                Text(
                  l10n.tapToRate,
                  style: const TextStyle(
                    color: AppColors.onCardMuted,
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const HGap.sm(),
          for (var stars = 1; stars <= 5; stars++)
            Semantics(
              button: true,
              label: '$stars',
              child: InkResponse(
                onTap: () => onRate(stars),
                radius: 18,
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    stars <= myRating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 26,
                    color: stars <= myRating
                        ? AppColors.accent
                        : AppColors.onCardDisabled,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _RatingBreakdown extends StatelessWidget {
  const _RatingBreakdown({required this.summary});

  final RatingSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(summary.average.toStringAsFixed(1),
                  style: theme.textTheme.displayLarge),
              Text(l10n.reviewCount(summary.total),
                  style: theme.textTheme.bodySmall),
            ],
          ),
          const HGap.lg(),
          Expanded(
            child: Column(
              children: [
                for (var stars = 5; stars >= 1; stars--)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 12,
                          child: Text('$stars',
                              style: theme.textTheme.labelSmall),
                        ),
                        const HGap.sm(),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: summary.fraction(stars),
                              minHeight: 7,
                              backgroundColor: AppColors.creamSunken,
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.accent),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.cream,
                child: Text(
                  review.authorName.isEmpty
                      ? '?'
                      : review.authorName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.onCream,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const HGap.md(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.authorName,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: AppColors.onCard),
                    ),
                    Text(
                      Formatters.relative(review.createdAt),
                      style: const TextStyle(
                          color: AppColors.onCardMuted, fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  for (var i = 1; i <= 5; i++)
                    Icon(
                      i <= review.rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 14,
                      color: i <= review.rating
                          ? AppColors.accent
                          : AppColors.onCardDisabled,
                    ),
                ],
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const Gap.md(),
            Text(
              review.comment!,
              // Reviews arrive in Kurdish, Arabic or English; let the text
              // pick its own direction rather than inheriting the UI's.
              textDirection: null,
              style: const TextStyle(
                color: AppColors.onCard,
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ],
          if (review.reply != null) ...[
            const Gap.md(),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: const BoxDecoration(
                color: AppColors.cardDarkAlt,
                borderRadius: AppRadius.chipR,
                border: Border(
                  left: BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.replyFromCafe,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Gap.xs(),
                  Text(
                    review.reply!.body,
                    style: const TextStyle(
                        color: AppColors.onCardMuted, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.color = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: Material(
          color: AppColors.badge.withValues(alpha: 0.55),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, color: color, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

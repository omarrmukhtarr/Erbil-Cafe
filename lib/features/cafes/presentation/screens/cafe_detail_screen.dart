import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../favorites/data/favorites_repository.dart';
import '../../../menu/data/repositories/menu_repository.dart';
import '../../../reviews/data/models/review.dart';
import '../../../reviews/data/repositories/review_repository.dart';
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
            return Scaffold(
              appBar: AppBar(),
              body: ErrorView(
                failure: state.failure!,
                onRetry: () => _cubit.load(widget.slug),
              ),
            );
          }

          final detail = state.detail!;
          final cafe = detail.cafe;

          return CustomScrollView(
            slivers: [
              // Full-bleed header image with the content sheet riding over it,
              // as in v1's café pages.
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                backgroundColor: theme.colorScheme.surface,
                leading: _CircleButton(
                  icon: Icons.arrow_back,
                  onTap: () => context.pop(),
                ),
                actions: [
                  _CircleButton(
                    icon: cafe.isFavorited
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: cafe.isFavorited ? AppColors.accent : Colors.white,
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
                  const SizedBox(width: AppSpacing.sm),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'cafe-image-${cafe.id}',
                        child: cafe.coverImage == null
                            ? ColoredBox(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                              )
                            : CachedNetworkImage(
                                imageUrl: cafe.coverImage!,
                                fit: BoxFit.cover,
                                placeholder: (context, _) => ColoredBox(
                                  color: theme
                                      .colorScheme.surfaceContainerHighest,
                                ),
                                errorWidget: (context, _, __) => ColoredBox(
                                  color: theme
                                      .colorScheme.surfaceContainerHighest,
                                ),
                              ),
                      ),
                      const DecoratedBox(
                        decoration:
                            BoxDecoration(gradient: AppColors.imageScrim),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(cafe.name,
                                style: theme.textTheme.headlineMedium),
                          ),
                          Text(
                            cafe.priceRange.symbol,
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: AppColors.accent),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      Row(
                        children: [
                          if (cafe.reviewCount > 0) ...[
                            const Icon(Icons.star_rounded,
                                size: 18, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              cafe.ratingAvg.toStringAsFixed(1),
                              style: theme.textTheme.labelLarge,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              l10n.reviewCount(cafe.reviewCount),
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(width: AppSpacing.md),
                          ],
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: cafe.isOpenNow
                                ? AppColors.success
                                : AppColors.textDisabled,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cafe.isOpenNow ? l10n.openNow : l10n.closed,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cafe.isOpenNow
                                  ? AppColors.success
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      if (cafe.description.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(cafe.description,
                            style: theme.textTheme.bodyMedium),
                      ],

                      const SizedBox(height: AppSpacing.xl),

                      // Quick actions
                      Row(
                        children: [
                          if (detail.phone != null)
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.phone_outlined,
                                label: l10n.call,
                                onTap: () => _open('tel:${detail.phone}'),
                              ),
                            ),
                          if (detail.phone != null)
                            const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.directions_outlined,
                              label: l10n.directions,
                              onTap: () => _open(
                                'https://www.google.com/maps/dir/?api=1'
                                '&destination=${cafe.lat},${cafe.lng}',
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.menu_book_outlined,
                              label: l10n.menu,
                              onTap: () =>
                                  context.push(Routes.menu(widget.slug)),
                            ),
                          ),
                        ],
                      ),

                      if (cafe.amenities.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        Text(l10n.amenities,
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.md),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final amenity in cafe.amenities)
                              Chip(
                                label: Text(amenity.name),
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                              ),
                          ],
                        ),
                      ],

                      if (detail.images.length > 1) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        Text(l10n.gallery, style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: detail.images.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final image = detail.images[index];
                              return ClipRRect(
                                borderRadius: AppRadius.chipR,
                                child: CachedNetworkImage(
                                  imageUrl: image.thumbUrl ?? image.url,
                                  width: 140,
                                  fit: BoxFit.cover,
                                  placeholder: (context, _) => Container(
                                    width: 140,
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                  ),
                                  errorWidget: (context, _, __) => Container(
                                    width: 140,
                                    color: theme
                                        .colorScheme.surfaceContainerHighest,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      if (detail.openingHours.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xxl),
                        Text(l10n.openingHours,
                            style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.md),
                        _OpeningHours(hours: detail.openingHours),
                      ],

                      // ─── Reviews ─────────────────────────────────
                      const SizedBox(height: AppSpacing.xxl),
                      Row(
                        children: [
                          Expanded(
                            child: Text(l10n.reviews,
                                style: theme.textTheme.titleMedium),
                          ),
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

                      if (state.summary.total > 0)
                        _RatingBreakdown(summary: state.summary),

                      const SizedBox(height: AppSpacing.md),

                      if (state.reviews.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.xl),
                          child: Center(
                            child: Text(
                              l10n.noReviewsYet,
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                        )
                      else
                        for (final review in state.reviews.take(5))
                          _ReviewTile(review: review),

                      const SizedBox(height: AppSpacing.huge),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      // The booking CTA that v1 rendered as "Service Not Availabe For Now".
      bottomNavigationBar: BlocBuilder<CafeDetailCubit, CafeDetailState>(
        bloc: _cubit,
        builder: (context, state) {
          if (state.detail == null) return const SizedBox.shrink();

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: ElevatedButton.icon(
                onPressed: () => requireAuth(
                  context,
                  reason: l10n.signInToBook,
                  action: () async =>
                      context.push(Routes.book(widget.slug)),
                ),
                icon: const Icon(Icons.event_seat_outlined),
                label: Text(l10n.bookTable),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.color = Colors.white,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Material(
        color: AppColors.badge.withValues(alpha: 0.6),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Icon(icon, color: color, size: 20),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: AppRadius.inputR,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Column(
            children: [
              Icon(icon, size: 20, color: AppColors.accent),
              const SizedBox(height: 4),
              Text(label, style: theme.textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpeningHours extends StatelessWidget {
  const _OpeningHours({required this.hours});

  final List<dynamic> hours;

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

    final today = DateTime.now().weekday % 7;

    return Column(
      children: [
        for (final hour in hours)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    names[hour.dayOfWeek as int],
                    style: theme.textTheme.bodySmall?.copyWith(
                      // Highlight today so the current hours are findable.
                      color: hour.dayOfWeek == today
                          ? AppColors.accent
                          : AppColors.textMuted,
                      fontWeight: hour.dayOfWeek == today
                          ? FontWeight.w700
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Text(
                  hour.isClosed as bool
                      ? l10n.closed
                      : '${hour.opensAt} – ${hour.closesAt}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hour.dayOfWeek == today
                        ? AppColors.accent
                        : AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _RatingBreakdown extends StatelessWidget {
  const _RatingBreakdown({required this.summary});

  final RatingSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              Text(
                summary.average.toStringAsFixed(1),
                style: theme.textTheme.displayLarge,
              ),
              Text(
                '${summary.total}',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              children: [
                for (var stars = 5; stars >= 1; stars--)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 14,
                          child: Text(
                            '$stars',
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: summary.fraction(stars),
                              minHeight: 6,
                              backgroundColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              valueColor: const AlwaysStoppedAnimation(
                                AppColors.accent,
                              ),
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

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.cardR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.cream,
                child: Text(
                  review.authorName.isEmpty
                      ? '?'
                      : review.authorName[0].toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.background,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.authorName, style: theme.textTheme.labelLarge),
                    Text(
                      Formatters.relative(review.createdAt),
                      style: theme.textTheme.labelSmall,
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
                          : AppColors.textDisabled,
                    ),
                ],
              ),
            ],
          ),
          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(review.comment!, style: theme.textTheme.bodyMedium),
          ],
          if (review.reply != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: AppRadius.chipR,
                border: const Border(
                  left: BorderSide(color: AppColors.accent, width: 2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.replyFromCafe,
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: AppColors.accent),
                  ),
                  const SizedBox(height: 4),
                  Text(review.reply!.body, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

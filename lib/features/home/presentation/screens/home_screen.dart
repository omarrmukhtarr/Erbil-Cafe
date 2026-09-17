import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_motion.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/network/response_cache.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/cafe_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cafes/data/repositories/cafe_repository.dart';
import '../../../cafes/presentation/cubit/cafe_list_cubit.dart';
import '../../../favorites/presentation/toggle_favorite.dart';
import '../../../menu/data/models/menu.dart';
import '../../../notifications/presentation/notification_bell.dart';
import '../../../menu/data/repositories/menu_repository.dart';
import '../widgets/area_strip.dart';
import '../widgets/category_strip.dart';
import '../widgets/nearby_section.dart';
import '../widgets/popular_tile.dart';

/// The Home tab.
///
/// Replaces v1's `PopularScreen`, whose coffee tiles were a hardcoded widget
/// tree that opened one shared detail page whichever item was tapped.
///
/// The page answers four questions in the order people actually ask them:
/// *what kind of place am I after* (categories), *what is worth seeing*
/// (featured), *where can I go right now* (open now), *what do people order*
/// (popular), and *what is near which part of town* (areas). Every section is
/// a different slice of the same catalogue, so a small café list still fills
/// the screen with something useful.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final CafeListCubit _featured;
  late final CafeListCubit _openNow;
  late Future<List<PopularItem>> _popular;
  late Future<List<AmenityCount>> _categories;
  late Future<List<AreaCount>> _areas;

  final _popularReveal = RevealTracker();
  final _nearby = GlobalKey<NearbySectionState>();

  @override
  void initState() {
    super.initState();
    final cafes = sl<CafeRepository>();

    _featured = CafeListCubit(cafes)
      ..load(query: const CafeQuery(featured: true, limit: 6));
    _openNow = CafeListCubit(cafes)
      ..load(query: const CafeQuery(openNow: true, sort: 'rating', limit: 8));

    _popular = sl<MenuRepository>().popular();
    _categories = cafes.amenities();
    _areas = cafes.areas();
  }

  @override
  void dispose() {
    _featured.close();
    _openNow.close();
    super.dispose();
  }

  Future<void> _refresh() async {
    final cafes = sl<CafeRepository>();
    // A pull is an explicit "show me what is new"; the catalogue cache is what
    // it is asking to get past.
    ResponseCache.shared.clear();
    setState(() {
      _popular = sl<MenuRepository>().popular();
      _categories = cafes.amenities();
      _areas = cafes.areas();
    });
    await Future.wait([
      _featured.load(),
      _openNow.load(),
      if (_nearby.currentState != null) _nearby.currentState!.refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.accent,
          backgroundColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
          onRefresh: _refresh,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: _Greeting()),

              // ─── Categories ───────────────────────────────────────
              SliverToBoxAdapter(
                child: FutureBuilder<List<AmenityCount>>(
                  future: _categories,
                  builder: (context, snapshot) => FadeSwitcher(
                    child: CategoryStrip(
                      // Keyed on loading so the switcher sees the skeleton and
                      // the real strip as two different things to fade between.
                      key: ValueKey(!snapshot.hasData),
                      categories: snapshot.data ?? const [],
                      // A refresh keeps the strip it already has on screen.
                      loading:
                          snapshot.connectionState == ConnectionState.waiting &&
                              !snapshot.hasData,
                      onOpenNow: () =>
                          context.go(Routes.exploreWith(openNow: true)),
                      onNearMe: () =>
                          context.go(Routes.exploreWith(nearMe: true)),
                      onCategory: (key) =>
                          context.go(Routes.exploreWith(amenity: key)),
                    ),
                  ),
                ),
              ),

              // ─── Near you ─────────────────────────────────────────
              // Before Featured: a café two streets away is a better answer to
              // "where should I go" than a good one across town.
              SliverToBoxAdapter(child: NearbySection(key: _nearby)),

              // ─── Featured cafés ───────────────────────────────────
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: l10n.featured,
                  subtitle: l10n.featuredSubtitle,
                  actionLabel: l10n.seeAll,
                  onAction: () => context.go(Routes.explore),
                ),
              ),
              SliverToBoxAdapter(
                child: _CafeCarousel(cubit: _featured, cardWidth: 272),
              ),

              // ─── Open right now ───────────────────────────────────
              SliverToBoxAdapter(
                child: BlocBuilder<CafeListCubit, CafeListState>(
                  bloc: _openNow,
                  builder: (context, state) {
                    // A section that says "open now" and shows nothing is worse
                    // than no section, so it only appears once it has cafés.
                    if (state.status != ListStatus.loading &&
                        state.cafes.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return FadeSlideIn(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: l10n.openRightNow,
                            subtitle: l10n.openRightNowSubtitle,
                            actionLabel: l10n.seeAll,
                            onAction: () =>
                                context.go(Routes.exploreWith(openNow: true)),
                          ),
                          _CafeCarousel(cubit: _openNow, cardWidth: 272),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // ─── Popular items ────────────────────────────────────
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: l10n.popular,
                  subtitle: l10n.popularSubtitle,
                ),
              ),
              SliverToBoxAdapter(
                child: FutureBuilder<List<PopularItem>>(
                  future: _popular,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData &&
                        snapshot.connectionState == ConnectionState.waiting) {
                      return const FadeSwitcher(
                        child: SizedBox(
                          key: ValueKey('popular-loading'),
                          height: PopularTile.height,
                          child: _PopularSkeleton(),
                        ),
                      );
                    }

                    final items = snapshot.data ?? const <PopularItem>[];
                    if (items.isEmpty) return const SizedBox.shrink();

                    return FadeSwitcher(
                      child: SizedBox(
                        key: const ValueKey('popular'),
                        height: PopularTile.height,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          clipBehavior: Clip.none,
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.page),
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const HGap.md(),
                          itemBuilder: (context, index) => FadeSlideIn(
                            index: index,
                            animate: _popularReveal.shouldAnimate(
                              items[index].item.id,
                              index,
                            ),
                            child: PopularTile(item: items[index]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // ─── Areas ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: FutureBuilder<List<AreaCount>>(
                  future: _areas,
                  builder: (context, snapshot) {
                    final areas = snapshot.data ?? const <AreaCount>[];
                    if (areas.isEmpty) return const SizedBox.shrink();

                    return FadeSlideIn(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionHeader(
                            title: l10n.browseByArea,
                            subtitle: l10n.browseByAreaSubtitle,
                          ),
                          AreaStrip(
                            areas: areas,
                            onTap: (area) =>
                                context.go(Routes.exploreWith(area: area)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Clears the translucent tab bar.
              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.bottomBarClearance),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Title, tagline and the search shortcut.
class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final user = context.watch<AuthCubit>().state.user;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.lg,
        AppSpacing.md,
        0,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user == null
                      ? l10n.appName
                      : 'Hi, ${user.name.split(' ').first}',
                  style: theme.textTheme.displayLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap.xs(),
                Text(l10n.appTagline, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const HGap.sm(),
          const NotificationBell(),
          const HGap.sm(),
          _RoundAction(
            icon: Icons.search,
            tooltip: l10n.searchHint,
            onTap: () => context.go(Routes.explore),
          ),
        ],
      ),
    );
  }
}

/// A horizontal run of [CafeCard]s driven by a [CafeListCubit].
///
/// Both café sections on this page are the same carousel over a different
/// query, so the skeleton, the empty case and the fixed height live here once.
class _CafeCarousel extends StatefulWidget {
  const _CafeCarousel({required this.cubit, required this.cardWidth});

  final CafeListCubit cubit;
  final double cardWidth;

  @override
  State<_CafeCarousel> createState() => _CafeCarouselState();
}

class _CafeCarouselState extends State<_CafeCarousel> {
  final _reveal = RevealTracker();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CafeListCubit, CafeListState>(
      bloc: widget.cubit,
      builder: (context, state) {
        // Only a first load shows skeletons. A pull-to-refresh keeps the cards
        // it has until the new ones arrive.
        if (state.isFirstLoad || state.status == ListStatus.initial) {
          return FadeSwitcher(
            child: SizedBox(
              key: const ValueKey('loading'),
              height: CafeCard.compactHeight,
              child: SkeletonGroup(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  itemCount: 2,
                  separatorBuilder: (_, __) => const HGap.lg(),
                  itemBuilder: (context, _) => SizedBox(
                    width: widget.cardWidth,
                    child: const CafeCardSkeleton(compact: true),
                  ),
                ),
              ),
            ),
          );
        }

        if (state.cafes.isEmpty) return const SizedBox.shrink();

        return FadeSwitcher(
          child: SizedBox(
            key: const ValueKey('cafes'),
            height: CafeCard.compactHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              itemCount: state.cafes.length,
              separatorBuilder: (_, __) => const HGap.lg(),
              itemBuilder: (context, index) {
                final cafe = state.cafes[index];
                return FadeSlideIn(
                  index: index,
                  animate: _reveal.shouldAnimate(cafe.id, index),
                  child: SizedBox(
                    width: widget.cardWidth,
                    child: CafeCard(
                      cafe: cafe,
                      compact: true,
                      onTap: () =>
                          context.push(Routes.cafe(cafe.slug), extra: cafe),
                      onFavoriteTap: () => toggleFavorite(context, cafe),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// Tile-shaped placeholders for the popular row.
class _PopularSkeleton extends StatelessWidget {
  const _PopularSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonGroup(
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        itemCount: 3,
        separatorBuilder: (_, __) => const HGap.md(),
        itemBuilder: (context, _) => const SizedBox(
          width: PopularTile.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(
                height: PopularTile.imageHeight,
                radius: AppRadius.card,
              ),
              Gap.md(),
              AppSkeleton(height: 14, width: 110),
              Gap.sm(),
              AppSkeleton(height: 11, width: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundAction extends StatelessWidget {
  const _RoundAction({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, size: 22, color: theme.colorScheme.onSurface),
          ),
        ),
      ),
    );
  }
}

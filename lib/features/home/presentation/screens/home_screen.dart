import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/injector.dart';
import '../../../../app/router/app_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/cafe_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../cafes/data/models/cafe.dart';
import '../../../cafes/data/repositories/cafe_repository.dart';
import '../../../cafes/presentation/cubit/cafe_list_cubit.dart';
import '../../../favorites/data/favorites_repository.dart';
import '../../../menu/data/models/menu.dart';
import '../../../menu/data/repositories/menu_repository.dart';
import '../widgets/area_strip.dart';
import '../widgets/category_strip.dart';
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
    setState(() {
      _popular = sl<MenuRepository>().popular();
      _categories = cafes.amenities();
      _areas = cafes.areas();
    });
    await Future.wait([_featured.load(), _openNow.load()]);
  }

  /// Saves a café and reflects it in whichever carousels are showing it.
  void _toggleFavorite(Cafe cafe, String reason) => requireAuth(
        context,
        reason: reason,
        action: () async {
          final result = await sl<FavoritesRepository>().toggle(cafe.id);
          for (final cubit in [_featured, _openNow]) {
            cubit.applyFavorite(cafe.id, isFavorited: result);
          }
        },
      );

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
                  builder: (context, snapshot) => CategoryStrip(
                    categories: snapshot.data ?? const [],
                    loading:
                        snapshot.connectionState == ConnectionState.waiting,
                    onOpenNow: () =>
                        context.go(Routes.exploreWith(openNow: true)),
                    onCategory: (key) =>
                        context.go(Routes.exploreWith(amenity: key)),
                  ),
                ),
              ),

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
                child: _CafeCarousel(
                  cubit: _featured,
                  cardWidth: 272,
                  onFavorite: (cafe) =>
                      _toggleFavorite(cafe, l10n.signInToFavorite),
                ),
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

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: l10n.openRightNow,
                          subtitle: l10n.openRightNowSubtitle,
                          actionLabel: l10n.seeAll,
                          onAction: () =>
                              context.go(Routes.exploreWith(openNow: true)),
                        ),
                        _CafeCarousel(
                          cubit: _openNow,
                          cardWidth: 272,
                          onFavorite: (cafe) =>
                              _toggleFavorite(cafe, l10n.signInToFavorite),
                        ),
                      ],
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
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: PopularTile.height,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: AppSpacing.page),
                          child: AppSkeleton(
                            height: PopularTile.imageHeight,
                            radius: AppRadius.card,
                          ),
                        ),
                      );
                    }

                    final items = snapshot.data ?? const <PopularItem>[];
                    if (items.isEmpty) return const SizedBox.shrink();

                    return SizedBox(
                      height: PopularTile.height,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.none,
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.page),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const HGap.md(),
                        itemBuilder: (context, index) =>
                            PopularTile(item: items[index]),
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

                    return Column(
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
class _CafeCarousel extends StatelessWidget {
  const _CafeCarousel({
    required this.cubit,
    required this.cardWidth,
    required this.onFavorite,
  });

  final CafeListCubit cubit;
  final double cardWidth;
  final void Function(Cafe cafe) onFavorite;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CafeListCubit, CafeListState>(
      bloc: cubit,
      builder: (context, state) {
        if (state.status == ListStatus.loading) {
          return SizedBox(
            height: CafeCard.compactHeight,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              itemCount: 2,
              separatorBuilder: (_, __) => const HGap.lg(),
              itemBuilder: (context, _) => SizedBox(
                width: cardWidth,
                child: const CafeCardSkeleton(compact: true),
              ),
            ),
          );
        }

        if (state.cafes.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: CafeCard.compactHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            itemCount: state.cafes.length,
            separatorBuilder: (_, __) => const HGap.lg(),
            itemBuilder: (context, index) {
              final cafe = state.cafes[index];
              return SizedBox(
                width: cardWidth,
                child: CafeCard(
                  cafe: cafe,
                  compact: true,
                  onTap: () => context.push(Routes.cafe(cafe.slug)),
                  onFavoriteTap: () => onFavorite(cafe),
                ),
              );
            },
          ),
        );
      },
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
